class ProfessionalProfile < ApplicationRecord
  belongs_to :user

  enum :kind, { psychoanalyst: 0, psychologist: 1 }

  validates :kind, presence: true
  validates :crp, presence: true, format: { with: /\A\d{5,6}\/[A-Z]{2}\z/, message: :invalid }, if: :psychologist?

  def can_issue?(document_kind)
    return true if %w[attendance_declaration receipt progress_report].include?(document_kind.to_s)
    document_kind.to_s == "psychological_report" && psychologist?
  end
end
