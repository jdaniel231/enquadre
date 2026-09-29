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
end
