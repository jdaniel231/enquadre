class Appointment < ApplicationRecord
  belongs_to :patient
  belongs_to :account
  belongs_to :care_plan, optional: true

  enum :status, {
    scheduled: 0,
    attended: 1,
    absent_notified: 2,
    absent_late: 3,
    rescheduled: 4,
    cancelled_by_professional: 5
  }

  validates :scheduled_at, presence: true
  validates :status, presence: true

  scope :upcoming, -> { where("scheduled_at >= ?", Time.current).order(:scheduled_at) }
  scope :past, -> { where("scheduled_at < ?", Time.current).order(scheduled_at: :desc) }

  def fee
    fee_cents / 100.0 if fee_cents
  end

  def fee=(value)
    self.fee_cents = (value.to_f * 100).round if value.present?
  end

  def duration_minutes
    care_plan&.session_duration_minutes || 50
  end
end
