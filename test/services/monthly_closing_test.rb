require "test_helper"

class MonthlyClosingTest < ActiveSupport::TestCase
  YEAR  = 2026
  MONTH = 9

  setup do
    @account = accounts(:consultorio_um)
    @patient = @account.patients.create!(full_name: "Paciente Teste")
  end

  # ── Modalidade mensal ──────────────────────────────────────────────────────

  test "monthly: cobra fee fixo independente de attendance" do
    plan = monthly_plan(fee_cents: 80_000)
    appt(:attended, plan)
    appt(:absent_late, plan)

    charge = close(plan)
    assert_equal 80_000, charge.amount_cents
  end

  test "monthly: cobra fee fixo mesmo sem nenhuma sessão no mês" do
    plan = monthly_plan(fee_cents: 80_000)

    charge = close(plan)
    assert_equal 80_000, charge.amount_cents
  end

  # ── Modalidade por sessão ──────────────────────────────────────────────────

  test "per_session: cobra apenas sessões realizadas" do
    plan = per_session_plan(fee_cents: 25_000)
    appt(:attended, plan)
    appt(:attended, plan)
    appt(:absent_notified, plan)

    charge = close(plan)
    assert_equal 50_000, charge.amount_cents
  end

  test "per_session: absent_late cobrado quando política permite" do
    policy(:charge_absent_late, true)
    plan = per_session_plan(fee_cents: 25_000)
    appt(:absent_late, plan)

    charge = close(plan)
    assert_equal 25_000, charge.amount_cents
  end

  test "per_session: absent_late não cobrado quando política não permite" do
    policy(:charge_absent_late, false)
    plan = per_session_plan(fee_cents: 25_000)
    appt(:absent_late, plan)

    charge = close(plan)
    assert_equal 0, charge.amount_cents
  end

  test "per_session: absent_notified cobrado quando política permite" do
    policy(:charge_absent_notified, true)
    plan = per_session_plan(fee_cents: 25_000)
    appt(:absent_notified, plan)

    charge = close(plan)
    assert_equal 25_000, charge.amount_cents
  end

  test "per_session: absent_notified não cobrado por padrão" do
    plan = per_session_plan(fee_cents: 25_000)
    appt(:absent_notified, plan)

    charge = close(plan)
    assert_equal 0, charge.amount_cents
  end

  test "per_session: rescheduled não é cobrado" do
    plan = per_session_plan(fee_cents: 25_000)
    appt(:rescheduled, plan)

    charge = close(plan)
    assert_equal 0, charge.amount_cents
  end

  test "per_session: cancelled_by_professional não é cobrado" do
    plan = per_session_plan(fee_cents: 25_000)
    appt(:cancelled_by_professional, plan)

    charge = close(plan)
    assert_equal 0, charge.amount_cents
  end

  test "per_session: scheduled pendente não é cobrado" do
    plan = per_session_plan(fee_cents: 25_000)
    appt(:scheduled, plan)

    charge = close(plan)
    assert_equal 0, charge.amount_cents
  end

  test "per_session: usa fee da sessão quando diferente do plano" do
    plan = per_session_plan(fee_cents: 25_000)
    appt(:attended, plan, fee_cents: 30_000)

    charge = close(plan)
    assert_equal 30_000, charge.amount_cents
  end

  test "fechar o mesmo mês duas vezes atualiza o charge existente" do
    plan = per_session_plan(fee_cents: 25_000)
    appt(:attended, plan)

    close(plan)
    appt(:attended, plan)
    close(plan)

    assert_equal 1, Charge.where(patient: @patient, year: YEAR, month: MONTH).count
    assert_equal 50_000, Charge.find_by(patient: @patient, year: YEAR, month: MONTH).amount_cents
  end

  private

  def monthly_plan(fee_cents:)
    @account.care_plans.create!(
      patient: @patient, billing_mode: :monthly,
      sessions_per_week: 2, fee_cents: fee_cents
    )
  end

  def per_session_plan(fee_cents:)
    @account.care_plans.create!(
      patient: @patient, billing_mode: :per_session,
      sessions_per_week: 2, fee_cents: fee_cents
    )
  end

  def appt(status, plan, fee_cents: nil)
    @account.appointments.create!(
      patient: @patient, care_plan: plan,
      scheduled_at: Time.zone.local(YEAR, MONTH, 10, 10, 0),
      status: status,
      fee_cents: fee_cents
    )
  end

  def policy(field, value)
    @account.create_absence_policy!(field => value)
  end

  def close(plan)
    MonthlyClosing.new(patient: @patient, care_plan: plan, year: YEAR, month: MONTH).call
  end
end
