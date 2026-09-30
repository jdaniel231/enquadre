class PatientsController < ApplicationController
  before_action :set_patient, only: %i[show edit update]

  def index
    @patients = Current.account.patients.order(:full_name)
  end

  def show
    @care_plans = @patient.care_plans.order(active: :desc, created_at: :desc)
    @record_entries = @patient.record_entries.order(created_at: :desc)
    @private_notes = @patient.private_notes.authored_by(Current.user).order(created_at: :desc)
    @issued_documents = @patient.issued_documents.order(created_at: :desc)
  end

  def new
    @patient = Current.account.patients.new
  end

  def create
    @patient = Current.account.patients.new(patient_params)
    if @patient.save
      redirect_to @patient, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @patient.update(patient_params)
      redirect_to @patient, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_patient
    @patient = Current.account.patients.find(params[:id])
  end

  def patient_params
    params.expect(patient: [ :full_name, :cpf, :phone, :email, :date_of_birth, :notes ])
  end
end
