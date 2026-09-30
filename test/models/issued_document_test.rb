require "test_helper"

class IssuedDocumentTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:consultorio_um)
    @psychologist = users(:one)
    @psychoanalyst = users(:three)
    @patient = @account.patients.create!(full_name: "Paciente Teste")
  end

  test "psychologist can issue all document kinds" do
    IssuedDocument.kinds.each_key do |kind|
      doc = IssuedDocument.new(
        patient: @patient, account: @account, user: @psychologist,
        kind: kind, content: "Conteúdo.", rendered_html: "<p>ok</p>"
      )
      assert doc.valid?, "#{kind} deve ser válido para psicólogo: #{doc.errors.full_messages}"
    end
  end

  test "psychoanalyst cannot issue psychological_report" do
    doc = IssuedDocument.new(
      patient: @patient, account: @account, user: @psychoanalyst,
      kind: :psychological_report, content: "Conteúdo.", rendered_html: "<p>ok</p>"
    )
    assert_not doc.valid?
    assert doc.errors[:kind].any?
  end

  test "psychoanalyst can issue attendance_declaration, receipt and progress_report" do
    %i[attendance_declaration receipt progress_report].each do |kind|
      doc = IssuedDocument.new(
        patient: @patient, account: @account, user: @psychoanalyst,
        kind: kind, content: "Conteúdo.", rendered_html: "<p>ok</p>"
      )
      assert doc.valid?, "#{kind} deve ser válido para psicanalista: #{doc.errors.full_messages}"
    end
  end

  test "destroy is blocked" do
    doc = IssuedDocument.create!(
      patient: @patient, account: @account, user: @psychologist,
      kind: :receipt, content: "Conteúdo.", rendered_html: "<p>ok</p>"
    )
    assert_no_difference "IssuedDocument.count" do
      doc.destroy
    end
  end
end
