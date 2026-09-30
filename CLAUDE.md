# CLAUDE.md — Enquadre

Este arquivo orienta o Claude (e qualquer pessoa nova no projeto) sobre como o Enquadre é construído. Leia inteiro antes de gerar código. Quando uma regra daqui conflitar com um hábito genérico de Rails, vale a regra daqui.

## O que é o produto

O Enquadre é um micro-SaaS de prontuário, agenda, financeiro e documentos para psicanalistas no Brasil. O público se divide em dois grupos: psicanalistas que também são psicólogos (com CRP) e psicanalistas sem registro em conselho. Essa diferença muda o que cada um pode emitir, então ela aparece no modelo de dados e nas permissões.

A ideia central do produto é a separação entre dois tipos de registro clínico. O **prontuário** é o registro formal, sóbrio, que o paciente pode solicitar e que precisa ser guardado. As **anotações privadas** são as notas de trabalho do analista (sonhos, associações, hipóteses sobre transferência) e pertencem só a quem escreveu. Nunca misture os dois.

## Stack

Rails 8 full-stack, com views renderizadas no servidor. Não existe SPA nem API separada.

| Camada | Escolha |
|---|---|
| Linguagem | Ruby 3.3+, Rails 8 |
| Banco | PostgreSQL |
| Front-end | ERB + Hotwire (Turbo Frames, Turbo Streams, Stimulus) |
| CSS | Tailwind (`tailwindcss-rails`) |
| JS | Importmap, sem bundler Node |
| Assets | Propshaft |
| Autenticação | Gerador nativo do Rails 8 (`rails generate authentication`) + 2FA por TOTP |
| Jobs | Solid Queue |
| Cache / Cable | Solid Cache / Solid Cable |
| Criptografia | Active Record Encryption |
| Auditoria | gem `audited` |
| PDF | Grover (HTML para PDF), reaproveitando as views de pré-visualização |
| Testes | Minitest + fixtures, system tests com Capybara |
| Deploy | Kamal 2 + Thruster |

Não adicione Redis, Sidekiq, Devise, React, Webpack ou esbuild sem uma decisão explícita registrada na seção "Decisões" no fim deste arquivo. Se uma tela precisar de algo que o Hotwire não resolve bem (por exemplo, arrastar e soltar na agenda), use um Stimulus controller com uma biblioteca pontual via importmap, como Sortable.js.

## Comandos

```bash
bin/setup                 # instala dependências e prepara o banco
bin/dev                   # sobe servidor + watcher do Tailwind
bin/rails test            # testes unitários e de integração
bin/rails test:system     # testes de sistema (navegador)
bin/rubocop               # estilo (rubocop-rails-omakase)
bin/brakeman              # análise de segurança
bin/rails db:encryption:init   # gera chaves de criptografia (uma vez por ambiente)
```

Antes de considerar qualquer tarefa concluída, rode `bin/rails test`, `bin/rubocop` e `bin/brakeman`. Nenhum deles pode falhar.

## Idioma e convenções de nome

O código (classes, métodos, tabelas, colunas, rotas) é escrito em inglês. Textos de interface, mensagens de erro, e-mails e documentos gerados são em português do Brasil, sempre via `config/locales/pt-BR.yml`, nunca escritos direto na view.

Glossário do domínio:

| Português (interface) | Código | Observação |
|---|---|---|
| Consultório / conta | `Account` | O tenant. Tudo pertence a uma conta. |
| Profissional | `User` + `ProfessionalProfile` | O perfil guarda tipo de profissional e CRP. |
| Paciente | `Patient` | |
| Sessão (de análise) | `Appointment` | **Não use `Session`**: esse nome já é do login do Rails 8. |
| Plano de atendimento | `CarePlan` | Frequência semanal, modalidade de cobrança, valor. |
| Registro do prontuário | `RecordEntry` | Registro formal, criptografado, sem exclusão. |
| Anotação privada | `PrivateNote` | Visível só para o autor. |
| Política de faltas | `AbsencePolicy` | Regra de cobrança de faltas por conta. |
| Cobrança / fechamento do mês | `Charge` | Um por paciente por mês (mensal) ou por sessão. |
| Documento emitido | `IssuedDocument` | Declaração, recibo, relatório, laudo. |

Configuração regional: `config.i18n.default_locale = :"pt-BR"`, `config.time_zone = "America/Sao_Paulo"`. Datas exibidas como `28/09/2026`. Dinheiro é sempre guardado em centavos, em colunas inteiras com sufixo `_cents` (por exemplo, `amount_cents`), e formatado com `number_to_currency` em pt-BR. Nunca use float para valores.

## Multi-tenancy

Todo registro de domínio pertence a uma `Account`, direta ou indiretamente. A conta atual fica em `Current.account`, definida no `ApplicationController` a partir do usuário logado.

Toda consulta de domínio parte da conta atual: escreva `Current.account.patients.find(params[:id])`, nunca `Patient.find(params[:id])`. Um `find` fora do escopo da conta é tratado como bug de segurança, porque expõe dados de saúde de outro consultório. Os testes de controller devem incluir um caso que tenta acessar um recurso de outra conta e espera `404`.

## Dados sensíveis e LGPD

Dados de saúde são dados pessoais sensíveis pela LGPD. As regras abaixo não são opcionais.

**Criptografia.** Use `encrypts` nos campos com conteúdo clínico ou identificador pessoal: `RecordEntry#body`, `PrivateNote#body`, `Patient#full_name`, `Patient#cpf`, `Patient#phone`, `Patient#email`, `Patient#notes` e qualquer campo novo desse tipo. Campos que precisam de busca exata (como CPF) usam `encrypts ..., deterministic: true`. As chaves ficam em credentials, nunca no repositório em texto aberto.

**Logs.** Adicione todo campo sensível novo a `config/initializers/filter_parameter_logging.rb`. Conteúdo clínico nunca aparece em logs, mensagens de erro, jobs serializados em texto aberto, ferramentas de monitoramento ou mensagens de commit. Em exceções, registre IDs, nunca conteúdo.

**Auditoria.** `Patient`, `RecordEntry` e `IssuedDocument` usam `audited`. Leituras de prontuário também são registradas (quem abriu, quando), por meio de um `AccessLog` gravado no controller.

**Retenção.** `RecordEntry` e `IssuedDocument` não podem ser apagados pela aplicação. Não crie rota, action ou método `destroy` para eles. Correções em um registro geram uma nova versão (via `audited`) e ficam visíveis no histórico. Para psicólogos, a Resolução CFP 001/2009 exige guarda mínima de 5 anos; a política exata de retenção deve ser confirmada com assessoria jurídica antes do lançamento e registrada em "Decisões".

**Exportação.** O paciente tem direito de acesso ao próprio prontuário. A exportação inclui `RecordEntry` e `IssuedDocument` e **nunca** inclui `PrivateNote`.

**Seeds e fixtures.** Use apenas dados fictícios. Nunca copie dados reais de produção para desenvolvimento, testes ou exemplos.

## Anotações privadas

`PrivateNote` pertence a um `User` (o autor) e a um `Patient`. Só o autor lê, edita ou apaga. Isso vale inclusive para administradores da conta e para o suporte do Enquadre. A regra é aplicada no model/escopo (`PrivateNote.authored_by(Current.user)`) e coberta por teste.

Anotações privadas nunca entram em documentos emitidos, exportações, buscas globais, relatórios, e-mails ou notificações. Se no futuro existir o módulo de supervisão, o compartilhamento será uma cópia anonimizada e explícita, criada pelo autor, e nunca um acesso direto à nota original.

## Tipos de profissional e documentos

`ProfessionalProfile#kind` é um enum com `psychologist` e `psychoanalyst`. Psicólogos informam o CRP.

Documentos disponíveis por tipo:

| Documento (`IssuedDocument#kind`) | Psicanalista | Psicólogo com CRP |
|---|---|---|
| `attendance_declaration` (declaração de comparecimento) | sim | sim |
| `receipt` (recibo) | sim | sim |
| `progress_report` (relatório de acompanhamento) | sim | sim |
| `psychological_report` (laudo psicológico) | não | sim |

A regra é validada no model `IssuedDocument` (não só escondida na interface), e o botão aparece desabilitado com a explicação para quem não pode emitir. Documentos psicológicos de psicólogos seguem a Resolução CFP 06/2019. Declarações e recibos não contêm conteúdo clínico: informam presença, datas, horários e valores. Documentos emitidos ficam congelados: guardamos o HTML renderizado e o PDF gerado no momento da emissão, para que mudanças futuras nos modelos não alterem documentos já entregues.

## Agenda e financeiro

Um `CarePlan` define a frequência (1 a 4 sessões por semana), os horários recorrentes e a modalidade de cobrança (`monthly` ou `per_session`). Um job recorrente do Solid Queue gera os `Appointment` das próximas semanas a partir dos planos ativos.

`Appointment#status` é um enum: `scheduled`, `attended`, `absent_notified`, `absent_late`, `rescheduled`, `cancelled_by_professional`. A cobrança de faltas segue a `AbsencePolicy` da conta (por exemplo, faltas avisadas com menos de 24h são cobradas). O cálculo de fechamento do mês vive em um objeto próprio (`MonthlyClosing`) com testes cobrindo cada combinação de modalidade e status.

## Front-end

Siga o design aprovado no canvas "Enquadre — Prontuário para Psicanalistas": fundo papel `#F4F0E8`, texto `#1E1B18`, destaque `#8A3324`, títulos em Fraunces e textos em IBM Plex Sans. Defina essas cores como tema no Tailwind em vez de repetir hexadecimais nas views.

Prefira Turbo Frames para atualizar partes da tela (marcar falta num card da agenda, salvar um registro no prontuário) e Turbo Streams para respostas que alteram mais de um lugar. Stimulus controllers são pequenos, com um propósito cada, e ficam em `app/javascript/controllers`. Não escreva JavaScript que monte HTML; o HTML vem do servidor.

Acessibilidade mínima: botões são `<button>`, links são `<a>`, todo campo tem `<label>`, alvos de toque têm ao menos 44px e o contraste de texto respeita 4.5:1.

## Testes

Todo model, controller e job novo vem com teste. Casos obrigatórios quando se aplicam: isolamento entre contas (acesso a recurso de outra conta retorna 404), privacidade das anotações privadas (outro usuário da mesma conta não lê), bloqueio do laudo para psicanalista sem CRP, ausência de rota de exclusão para prontuário e documentos, e cálculo do fechamento mensal com faltas.

System tests cobrem as jornadas principais: cadastrar paciente com plano, registrar sessão no prontuário, marcar falta, fechar o mês e emitir uma declaração.

## Deploy e ambiente

Deploy com Kamal 2. Preferir hospedagem em região no Brasil (por exemplo, São Paulo). Backups diários do Postgres, criptografados, com teste de restauração documentado. Segredos sempre em `config/credentials` ou nos secrets do Kamal, nunca em `.env` versionado.

## O que não fazer

Não use `Session` como nome de model de domínio. Não faça `find` fora do escopo de `Current.account`. Não crie `destroy` para `RecordEntry` ou `IssuedDocument`. Não exponha `PrivateNote` fora do autor. Não coloque conteúdo clínico em logs, seeds ou mensagens de erro. Não use float para dinheiro. Não adicione dependências grandes sem registrar a decisão abaixo. Não envie dados de pacientes para serviços externos de IA sem uma decisão registrada, consentimento e opção desligada por padrão.

## Status de implementação

### Fundação (concluída em 2026-09-29)

| O que | Arquivo(s) principal(is) | Observação |
|---|---|---|
| Gems adicionadas | `Gemfile` | `tailwindcss-rails`, `audited`, `grover`, `bcrypt` |
| Locale pt-BR + timezone | `config/application.rb`, `config/locales/pt-BR.yml` | Datas, moeda, erros em português |
| Autenticação Rails 8 | `app/models/user.rb`, `app/controllers/concerns/authentication.rb` | `User`, `Session`, `Current` gerados pelo `rails generate authentication` |
| Multi-tenancy | `app/models/account.rb`, `app/models/current.rb`, `app/controllers/application_controller.rb` | `Current.account` delegado via `user`; helper `current_account` disponível nas views |
| Tema Tailwind | `app/assets/tailwind/application.css` | Cores `paper`/`ink`/`accent` + Fraunces + IBM Plex Sans via `@theme` |
| Chaves de criptografia | `config/credentials/development.yml.enc` | Geradas com `rails db:encryption:init`; produção pendente |
| Banco de dados | `db/schema.rb` | PostgreSQL; user `postgres`, banco `enquadre` em dev |

### Modelos de domínio (concluídos em 2026-09-29)

| Model | Campos relevantes | Destaque |
|---|---|---|
| `Account` | `name` | Tenant raiz; tudo pertence a uma conta |
| `User` | `email_address`, `password_digest`, `account_id` | `belongs_to :account`; `has_one :professional_profile` |
| `ProfessionalProfile` | `kind` (enum), `crp` | Enum `psychoanalyst / psychologist`; valida CRP com regex; método `can_issue?` |
| `Patient` | `full_name`, `cpf`, `phone`, `email`, `notes`, `date_of_birth` | Todos os campos PII com `encrypts`; `cpf` determinístico; `audited` |
| `CarePlan` | `billing_mode` (enum), `sessions_per_week`, `fee_cents` | Enum `monthly / per_session`; `sessions_per_week` 1–4 |
| `Appointment` | `scheduled_at`, `status` (enum), `fee_cents` | 6 status; scopes `upcoming` / `past` |
| `RecordEntry` | `body` (criptografado) | `audited`; `before_destroy { throw :abort }` impede exclusão |
| `PrivateNote` | `body` (criptografado) | Scope `authored_by(user)`; isolamento por autor |

### Fluxos de usuário (concluídos em 2026-09-29)

| Fluxo | Controller | Observação |
|---|---|---|
| Registro de conta | `RegistrationsController` | Cria `Account + User + ProfessionalProfile` em transação; Stimulus mostra/esconde CRP |
| Login / logout | `SessionsController` | Gerado pelo Rails 8 authentication |
| Recuperação de senha | `PasswordsController` | Gerado pelo Rails 8 authentication |

### Interfaces concluídas (2026-09-29)

| Tela | Controller | Observação |
|---|---|---|
| Dashboard | `DashboardController` | Cards de pacientes, sessões do dia e próximos agendamentos |
| Pacientes | `PatientsController` | CRUD completo; `find` sempre via `Current.account` |
| Plano de atendimento | `CarePlansController` | Nested em `Patient`; virtual attr `fee`/`fee_cents`; listado no `show` do paciente |
| Agenda | `AppointmentsController` | Visualização semanal; transições de status inline; criação e edição |
| Prontuário | `RecordEntriesController` | Nested em `Patient`; sem edit/destroy; seção no `show` do paciente |
| Anotações privadas | `PrivateNotesController` | Nested em `Patient`; isolamento por `authored_by(Current.user)`; CRUD completo |
| Documentos emitidos | `IssuedDocumentsController` | Nested em `Patient`; sem edit/destroy; HTML congelado na emissão; PDF via Grover; validação de `can_issue?` por tipo de profissional |

### Modelos de domínio adicionais (concluídos em 2026-09-30)

| Model | Campos relevantes | Destaque |
|---|---|---|
| `AbsencePolicy` | `charge_absent_late` (default `true`), `charge_absent_notified` (default `false`) | `has_one` de `Account`; `charges_for?(status)` consulta a política |
| `Charge` | `year`, `month`, `amount_cents`, `status` (enum) | Único por `patient + year + month`; criado/atualizado por `MonthlyClosing` |
| `IssuedDocument` | `kind` (enum), `content` (criptografado), `rendered_html` (criptografado), `amount_cents` | `audited`; destroy bloqueado; HTML congelado na criação; PDF gerado via Grover sob demanda |

### Serviços (concluídos em 2026-09-29)

| Serviço | Arquivo | Observação |
|---|---|---|
| `MonthlyClosing` | `app/services/monthly_closing.rb` | Calcula e persiste `Charge`; idempotente; usa `NullAbsencePolicy` quando conta não tem política configurada |

Regras de cálculo do `MonthlyClosing`:
- `monthly`: cobra `care_plan.fee_cents` fixo, independente de faltas ou ausências
- `per_session`: soma sessões cobráveis — `attended` sempre; `absent_late` / `absent_notified` conforme `AbsencePolicy`; `rescheduled` e `cancelled_by_professional` nunca cobram; fee da sessão tem prioridade sobre fee do plano quando presente

### Testes concluídos (2026-09-29)

| Teste | Arquivo |
|---|---|
| Isolamento entre contas — paciente de outra conta → 404 | `test/controllers/patients_controller_test.rb` |
| Isolamento entre contas — `RecordEntry` de outra conta → 404 | `test/controllers/record_entries_controller_test.rb` |
| Ausência de rota `DELETE` para `RecordEntry` | `test/controllers/record_entries_controller_test.rb` |
| Isolamento entre contas — `IssuedDocument` de outra conta → 404 | `test/controllers/issued_documents_controller_test.rb` |
| Ausência de rota `DELETE` para `IssuedDocument` | `test/controllers/issued_documents_controller_test.rb` |
| Psicanalista bloqueado de emitir laudo psicológico | `test/controllers/issued_documents_controller_test.rb` |
| `IssuedDocument` — todas as combinações tipo × profissional | `test/models/issued_document_test.rb` |
| Destroy de `IssuedDocument` bloqueado pelo model | `test/models/issued_document_test.rb` |
| Privacidade de `PrivateNote` — outro usuário da mesma conta → 404 | `test/controllers/private_notes_controller_test.rb` |
| `ProfessionalProfile#can_issue?` — todas as combinações tipo × documento | `test/models/professional_profile_test.rb` |
| `MonthlyClosing` — todas as combinações de `billing_mode × status` | `test/services/monthly_closing_test.rb` |

### Correções e infraestrutura (2026-09-29)

| Item | Arquivo | Observação |
|---|---|---|
| `filter_parameter_logging` | `config/initializers/filter_parameter_logging.rb` | Campos sensíveis adicionados: `full_name`, `cpf`, `body`, `date_of_birth`, etc. |
| YAML allowlist | `config/application.rb` | `yaml_column_permitted_classes` com `Date` para compatibilidade com `audited` + Psych 4 |
| Layout com navegação | `app/views/layouts/application.html.erb` | Header com nav, flash messages, `lang="pt-BR"` |
| Chaves AR Encryption no ambiente de teste | `config/environments/test.rb` | Chaves fixas em texto — dados de teste não são segredos |
| Puppeteer (Grover/PDF) | `package.json`, `node_modules/` | `npm install puppeteer` na raiz do projeto; `node_modules/` no `.gitignore` |

---

### Pendente

#### Modelos ainda não criados

| Model | Depende de | Prioridade |
|---|---|---|
| `AccessLog` | `User`, `RecordEntry` | Média — auditoria de leitura de prontuário (LGPD) |

#### Interfaces ainda não criadas

| Tela | Observação |
|---|---|
| Fechamento do mês — interface para `MonthlyClosing` | Serviço concluído; falta tela de fechamento e listagem de `Charge` |

#### Segurança / compliance pendentes

| Item | Observação |
|---|---|
| 2FA por TOTP | Previsto na stack; ainda não implementado |
| Exportação LGPD | `RecordEntry` + `IssuedDocument` por paciente; nunca `PrivateNote` |
| Chaves de criptografia em produção | Gerar e configurar via Kamal secrets antes do deploy |

#### Testes pendentes

| Teste | Motivo |
|---|---|
| System tests das jornadas principais | Cadastrar paciente, registrar sessão, marcar falta, fechar mês, emitir declaração |

#### Infraestrutura pendente

| Item | Observação |
|---|---|
| Job recorrente (Solid Queue) | Gerar `Appointment` das próximas semanas a partir de `CarePlan` ativos |
| Seeds com dados fictícios | Para desenvolvimento e demos |
| Deploy (Kamal 2) | Configurar `config/deploy.yml`, secrets, região Brasil |
| Backups do Postgres | Criptografados, com teste de restauração |

## Decisões

Registre aqui, com data, toda decisão de arquitetura que mude algo deste arquivo.

- 2026-09-29: Rails 8 full-stack com Hotwire, sem API separada. React só pontualmente, se uma tela exigir.
- 2026-09-29: PostgreSQL em produção.
- 2026-09-29: Nome do produto: Enquadre (verificar domínio e registro no INPI, classe 42).
- 2026-09-29: `Registration` implementado como objeto ActiveModel puro (não persiste diretamente), criando `Account + User + ProfessionalProfile` em transação única. Sem model `Registration` na base.
- 2026-09-29: `Appointment` referencia `CarePlan` como `optional: true` — uma sessão avulsa pode existir fora de um plano. `RecordEntry` referencia `Appointment` como `optional: true` — registro pode ser criado sem sessão associada.
- 2026-09-30: `IssuedDocument#rendered_html` armazena o fragmento HTML do corpo do documento (sem layout completo), gerado via `render_to_string` na criação. PDF gerado sob demanda pela action `pdf` usando Grover + Puppeteer. Input do usuário sanitizado via `sanitize` antes de entrar no HTML armazenado.
