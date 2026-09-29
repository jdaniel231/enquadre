class MonthlyClosing
  # Calcula e persiste o Charge de um paciente para um mês.
  # Retorna o Charge (criado ou atualizado).
  def initialize(patient:, care_plan:, year:, month:)
    @patient    = patient
    @care_plan  = care_plan
    @year       = year
    @month      = month
    @policy     = patient.account.absence_policy || NullAbsencePolicy.new
  end

  def call
    amount = calculate_amount

    charge = Charge.find_or_initialize_by(patient: @patient, year: @year, month: @month)
    charge.assign_attributes(
      care_plan:    @care_plan,
      account:      @patient.account,
      amount_cents: amount
    )
    charge.save!
    charge
  end

  private

  def calculate_amount
    if @care_plan.monthly?
      @care_plan.fee_cents
    else
      per_session_amount
    end
  end

  def per_session_amount
    appointments_in_month.sum do |appt|
      billable?(appt) ? session_fee(appt) : 0
    end
  end

  def billable?(appt)
    appt.attended? || @policy.charges_for?(appt.status)
  end

  def session_fee(appt)
    appt.fee_cents || @care_plan.fee_cents
  end

  def appointments_in_month
    range = Date.new(@year, @month, 1).beginning_of_day..Date.new(@year, @month, -1).end_of_day
    @patient.appointments.where(scheduled_at: range)
  end

  # Usado quando a conta ainda não configurou uma AbsencePolicy.
  # ponytail: evita nil-check espalhado — padrão Null Object
  class NullAbsencePolicy
    def charges_for?(_status) = false
  end
end
