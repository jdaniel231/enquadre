class IssuedDocument < ApplicationRecord
  belongs_to :patient
  belongs_to :account
  belongs_to :user

  encrypts :content
  encrypts :rendered_html

  audited

  enum :kind, {
    attendance_declaration: 0,
    receipt: 1,
    progress_report: 2,
    psychological_report: 3
  }

  validates :kind, presence: true
  validates :content, presence: true
  validates :rendered_html, presence: true
  validate :professional_can_issue

  # ponytail: impede destroy via ActiveRecord — rotas também não devem existir
  before_destroy { throw :abort }

  def amount
    amount_cents / 100.0 if amount_cents
  end

  def amount=(value)
    self.amount_cents = value.present? ? (value.to_f * 100).round : nil
  end

  private

  def professional_can_issue
    return unless kind && user
    profile = user.professional_profile
    return errors.add(:base, :no_profile) unless profile
    errors.add(:kind, :not_allowed) unless profile.can_issue?(kind)
  end
end
