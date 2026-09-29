class AppointmentsController < ApplicationController
  CALENDAR_START = 7
  CALENDAR_END   = 21

  before_action :set_appointment, only: %i[show edit update]
  before_action :set_form_data,   only: %i[new create edit update]

  def index
    @week_start = params[:week] ? Date.parse(params[:week]) : Date.current.beginning_of_week(:monday)
    @week_end   = @week_start + 6.days
    @week_days  = (@week_start..@week_end).to_a

    appointments = Current.account.appointments
      .where(scheduled_at: @week_start.beginning_of_day..@week_end.end_of_day)
      .includes(:patient, :care_plan)
      .order(:scheduled_at)

    @by_day = appointments.group_by { |a| a.scheduled_at.in_time_zone.to_date }
  end

  def show
  end

  def new
    @appointment = Current.account.appointments.new(status: :scheduled)
    if params[:at].present?
      @appointment.scheduled_at = Time.zone.parse(params[:at])
    end
  end

  def create
    @appointment = Current.account.appointments.new(appointment_params)
    if @appointment.save
      redirect_to appointments_path(week: @appointment.scheduled_at.to_date.beginning_of_week(:monday)),
                  notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @appointment.update(appointment_params)
      redirect_to appointments_path(week: @appointment.scheduled_at.to_date.beginning_of_week(:monday)),
                  notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_appointment
    @appointment = Current.account.appointments.find(params[:id])
  end

  def set_form_data
    @patients = Current.account.patients.order(:full_name)
  end

  def appointment_params
    params.expect(appointment: [ :patient_id, :care_plan_id, :scheduled_at, :status, :fee, :notes ])
  end
end
