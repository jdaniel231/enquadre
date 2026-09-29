class Patient < ApplicationRecord
  belongs_to :account

  encrypts :full_name
  encrypts :cpf, deterministic: true
  encrypts :phone
  encrypts :email
  encrypts :notes

  audited

  validates :full_name, presence: true

  has_many :care_plans, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :record_entries, dependent: :destroy
  has_many :private_notes, dependent: :destroy

  scope :for_account, ->(account) { where(account: account) }
end
