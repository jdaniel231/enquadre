class RecordEntriesController < ApplicationController
  before_action :set_patient

  def index
    @record_entries = @patient.record_entries.order(created_at: :desc)
  end

  def show
    @record_entry = @patient.record_entries.find(params[:id])
  end

  def new
    @record_entry = @patient.record_entries.new
  end

  def create
    @record_entry = @patient.record_entries.new(record_entry_params)
    @record_entry.account = Current.account
    @record_entry.user = Current.user

    if @record_entry.save
      redirect_to patient_record_entry_path(@patient, @record_entry), notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_patient
    @patient = Current.account.patients.find(params[:patient_id])
  end

  def record_entry_params
    params.expect(record_entry: [ :body, :appointment_id ])
  end
end
