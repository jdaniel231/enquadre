require "test_helper"

class IssuedDocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_a = users(:one)
    @user_b = users(:two)
    @account_a = accounts(:consultorio_um)
    @account_b = accounts(:consultorio_dois)

    @user_b.create_professional_profile!(kind: :psychologist, crp: "99999/SP")

    @patient_a = @account_a.patients.create!(full_name: "Paciente A")
    @patient_b = @account_b.patients.create!(full_name: "Paciente B")
    @doc_a = @account_a.issued_documents.create!(
      patient: @patient_a, user: @user_a,
      kind: :receipt, content: "Conteúdo.", rendered_html: "<p>ok</p>"
    )
    @doc_b = @account_b.issued_documents.create!(
      patient: @patient_b, user: @user_b,
      kind: :receipt, content: "Conteúdo.", rendered_html: "<p>ok</p>"
    )
  end

  test "user cannot access issued document from another account" do
    sign_in_as(@user_a)
    get patient_issued_document_path(@patient_b, @doc_b)
    assert_response :not_found
  end

  test "user can access own account issued document" do
    sign_in_as(@user_a)
    get patient_issued_document_path(@patient_a, @doc_a)
    assert_response :success
  end

  test "no destroy route exists for issued documents" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path(
        "/patients/#{@patient_a.id}/issued_documents/#{@doc_a.id}",
        method: :delete
      )
    end
  end

  test "psychoanalyst without CRP cannot create psychological_report" do
    psychoanalyst = users(:three)
    sign_in_as(psychoanalyst)
    patient = @account_a.patients.create!(full_name: "Paciente X")

    assert_no_difference "IssuedDocument.count" do
      post patient_issued_documents_path(patient), params: {
        issued_document: { kind: "psychological_report", content: "Laudo." }
      }
    end
    assert_response :unprocessable_entity
  end
end
