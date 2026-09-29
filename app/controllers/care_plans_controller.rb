class CarePlansController < ApplicationController
  before_action :set_patient, only: %i[index new create]
  before_action :set_care_plan, only: %i[edit update]

  def index
    care_plans = @patient.care_plans.where(active: true).order(created_at: :desc)
    render json: care_plans.map { |cp|
      {
        id: cp.id,
        label: "#{number_to_currency(cp.fee, unit: 'R$', separator: ',', delimiter: '.')} / #{I18n.t("care_plans.billing_modes.#{cp.billing_mode}").downcase}",
        fee: cp.fee,
        duration: cp.session_duration_minutes
      }
    }
  end

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
