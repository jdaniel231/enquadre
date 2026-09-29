class CreateAppointments < ActiveRecord::Migration[8.1]
  def change
    create_table :appointments do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :care_plan, null: false, foreign_key: true
      t.datetime :scheduled_at, null: false
      t.integer :status, null: false, default: 0
      t.integer :fee_cents
      t.string :notes

      t.timestamps
    end
  end
end
