class CreateCharges < ActiveRecord::Migration[8.1]
  def change
    create_table :charges do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :care_plan, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.integer :year, null: false
      t.integer :month, null: false
      t.integer :amount_cents, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :charges, [ :patient_id, :year, :month ], unique: true
  end
end
