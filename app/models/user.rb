class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :account
  has_one :professional_profile, dependent: :destroy
  has_many :record_entries, dependent: :nullify
  has_many :private_notes, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
