class CreateCarePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :care_plans do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.integer :billing_mode, null: false, default: 0
      t.integer :sessions_per_week, null: false
      t.integer :session_duration_minutes, null: false, default: 50
      t.integer :fee_cents, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
