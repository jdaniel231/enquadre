import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["patientSelect", "carePlanSelect", "feeField"]

  connect() {
    // If editing an existing appointment, load care plans for current patient
    const patientId = this.patientSelectTarget.value
    if (patientId) this.fetchCarePlans(patientId)
  }

  loadCarePlans() {
    const patientId = this.patientSelectTarget.value
    this.carePlanSelectTarget.innerHTML = '<option value="">Carregando…</option>'
    if (!patientId) {
      this.carePlanSelectTarget.innerHTML = '<option value="">Selecione o paciente primeiro</option>'
      return
    }
    this.fetchCarePlans(patientId)
  }

  updateFee() {
    const selected = this.carePlanSelectTarget.selectedOptions[0]
    const fee = selected?.dataset.fee
    if (fee && !this.feeFieldTarget.value) {
      this.feeFieldTarget.value = fee
    }
  }

  fetchCarePlans(patientId) {
    fetch(`/patients/${patientId}/care_plans`, {
      headers: { Accept: "application/json", "X-Requested-With": "XMLHttpRequest" }
    })
      .then(r => r.json())
      .then(plans => {
        const currentId = this.carePlanSelectTarget.dataset.currentId
        const opts = ['<option value="">Sem plano (sessão avulsa)</option>']
        plans.forEach(p => {
          const selected = currentId && String(p.id) === String(currentId) ? " selected" : ""
          opts.push(`<option value="${p.id}" data-fee="${p.fee}"${selected}>${p.label}</option>`)
        })
        this.carePlanSelectTarget.innerHTML = opts.join("")
        if (!this.feeFieldTarget.value) this.updateFee()
      })
      .catch(() => {
        this.carePlanSelectTarget.innerHTML = '<option value="">Erro ao carregar planos</option>'
      })
  }
}
