class AllowNullCarePlanInAppointments < ActiveRecord::Migration[8.1]
  def change
    change_column_null :appointments, :care_plan_id, true
  end
end
