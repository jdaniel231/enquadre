class Registration
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :account_name, :string
  attribute :email_address, :string
  attribute :password, :string
  attribute :kind, :string, default: "psychoanalyst"
  attribute :crp, :string

  attr_reader :user

  validates :account_name, presence: true
  validates :email_address, presence: true
  validates :password, presence: true, length: { minimum: 12 }
  validates :kind, inclusion: { in: ProfessionalProfile.kinds.keys }

  validate :crp_valid_for_psychologist

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      account = Account.create!(name: account_name)
      @user = account.users.create!(email_address: email_address, password: password)
      @user.create_professional_profile!(kind: kind, crp: crp.presence)
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    false
  end

  private

  def crp_valid_for_psychologist
    return unless kind == "psychologist"
    return if crp.present? && crp.match?(/\A\d{5,6}\/[A-Z]{2}\z/)
    errors.add(:crp, :invalid)
  end
end
