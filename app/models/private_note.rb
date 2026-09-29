class PrivateNote < ApplicationRecord
  belongs_to :patient
  belongs_to :user

  encrypts :body

  validates :body, presence: true

  scope :authored_by, ->(user) { where(user: user) }
end
