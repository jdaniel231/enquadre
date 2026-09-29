class Account < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :patients, dependent: :destroy
  has_many :care_plans, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :record_entries, dependent: :destroy

  validates :name, presence: true
end
