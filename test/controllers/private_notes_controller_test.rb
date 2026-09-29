require "test_helper"

class PrivateNotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author  = users(:one)
    @other   = users(:three)   # mesma conta, autor diferente
    @account = accounts(:consultorio_um)

    @patient = @account.patients.create!(full_name: "Paciente Teste")
    @note    = @patient.private_notes.create!(user: @author, body: "Nota privada do autor.")
  end

  test "author can edit own note" do
    sign_in_as(@author)
    get edit_patient_private_note_path(@patient, @note)
    assert_response :success
  end

  test "other user in same account cannot edit note" do
    sign_in_as(@other)
    get edit_patient_private_note_path(@patient, @note)
    assert_response :not_found
  end

  test "other user in same account cannot destroy note" do
    sign_in_as(@other)
    delete patient_private_note_path(@patient, @note)
    assert_response :not_found
    assert PrivateNote.exists?(@note.id), "nota não deve ser excluída"
  end

  test "author can destroy own note" do
    sign_in_as(@author)
    delete patient_private_note_path(@patient, @note)
    assert_redirected_to @patient
    assert_not PrivateNote.exists?(@note.id)
  end
end
