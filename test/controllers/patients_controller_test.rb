require "test_helper"

class PatientsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_a = users(:one)
    @user_b = users(:two)
    @account_a = accounts(:consultorio_um)
    @account_b = accounts(:consultorio_dois)

    @patient_a = @account_a.patients.create!(full_name: "Paciente A")
    @patient_b = @account_b.patients.create!(full_name: "Paciente B")
  end

  test "user cannot access patient from another account" do
    sign_in_as(@user_a)
    get patient_path(@patient_b)
    assert_response :not_found
  end

  test "user can access own account patient" do
    sign_in_as(@user_a)
    get patient_path(@patient_a)
    assert_response :success
  end
end
