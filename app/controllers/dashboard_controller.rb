class DashboardController < ApplicationController
  def index
    @patient_count = Current.account.patients.count
    @today_appointments = Current.account.appointments
      .where(scheduled_at: Time.current.beginning_of_day..Time.current.end_of_day)
      .order(:scheduled_at)
      .includes(:patient)
    @upcoming_appointments = Current.account.appointments.upcoming
      .where("scheduled_at > ?", Time.current.end_of_day)
      .limit(5)
      .includes(:patient)
  end
end
