class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :patients, dependent: :destroy
  has_many :care_plans, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :record_entries, dependent: :destroy
  has_many :issued_documents, dependent: :destroy
  has_many :charges, dependent: :destroy
  has_one  :absence_policy, dependent: :destroy

  validates :name, presence: true
end
