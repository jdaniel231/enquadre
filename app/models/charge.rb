class Charge < ApplicationRecord
  belongs_to :patient
  belongs_to :care_plan
  belongs_to :account

  enum :status, { open: 0, paid: 1 }

  validates :year, :month, :amount_cents, presence: true
  validates :month, inclusion: { in: 1..12 }
  validates :patient_id, uniqueness: { scope: [ :year, :month ] }
end
