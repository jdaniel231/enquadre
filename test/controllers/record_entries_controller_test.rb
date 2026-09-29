require "test_helper"

class RecordEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_a = users(:one)
    @user_b = users(:two)
    @account_a = accounts(:consultorio_um)
    @account_b = accounts(:consultorio_dois)

    @patient_a = @account_a.patients.create!(full_name: "Paciente A")
    @patient_b = @account_b.patients.create!(full_name: "Paciente B")
    @entry_a = @account_a.record_entries.create!(patient: @patient_a, user: @user_a, body: "Sessão inicial.")
    @entry_b = @account_b.record_entries.create!(patient: @patient_b, user: @user_b, body: "Entrada conta B.")
  end

  test "user cannot access record entry from another account" do
    sign_in_as(@user_a)
    get patient_record_entry_path(@patient_b, @entry_b)
    assert_response :not_found
  end

  test "user can access own account record entry" do
    sign_in_as(@user_a)
    get patient_record_entry_path(@patient_a, @entry_a)
    assert_response :success
  end

  test "no destroy route exists for record entries" do
    assert_raises(ActionController::RoutingError) do
      Rails.application.routes.recognize_path(
        "/patients/#{@patient_a.id}/record_entries/#{@entry_a.id}",
        method: :delete
      )
    end
  end
end
