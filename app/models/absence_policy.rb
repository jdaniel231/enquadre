class AbsencePolicy < ApplicationRecord
  belongs_to :account

  def charges_for?(status)
    case status.to_s
    when "absent_late"      then charge_absent_late?
    when "absent_notified"  then charge_absent_notified?
    else false
    end
  end
end
