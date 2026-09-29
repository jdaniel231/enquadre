class CarePlan < ApplicationRecord
  belongs_to :patient
  belongs_to :account
  has_many :appointments, dependent: :nullify

  enum :billing_mode, { monthly: 0, per_session: 1 }

  validates :sessions_per_week, presence: true, inclusion: { in: 1..4 }
  validates :session_duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :fee_cents, presence: true, numericality: { greater_than: 0 }
  validates :billing_mode, presence: true

  def fee
    fee_cents / 100.0 if fee_cents
  end

  def fee=(value)
    self.fee_cents = (value.to_f * 100).round
  end
end
