class CarePlansController < ApplicationController
  before_action :set_patient, only: %i[new create]
  before_action :set_care_plan, only: %i[edit update]

  def new
    @care_plan = @patient.care_plans.new
  end

  def create
    @care_plan = @patient.care_plans.new(care_plan_params)
    @care_plan.account = Current.account
    if @care_plan.save
      redirect_to @patient, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @care_plan.update(care_plan_params)
      redirect_to @care_plan.patient, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_patient
    @patient = Current.account.patients.find(params[:patient_id])
  end

  def set_care_plan
    @care_plan = Current.account.care_plans.find(params[:id])
    @patient = @care_plan.patient
  end

  def care_plan_params
    params.expect(care_plan: [ :fee, :billing_mode, :sessions_per_week, :session_duration_minutes, :active ])
  end
end
