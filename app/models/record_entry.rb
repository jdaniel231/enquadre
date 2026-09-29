class RecordEntry < ApplicationRecord
  belongs_to :patient
  belongs_to :account
  belongs_to :user
  belongs_to :appointment, optional: true

  encrypts :body

  audited

  validates :body, presence: true

  # ponytail: impede destroy via ActiveRecord — rotas também não devem existir
  before_destroy { throw :abort }
end
