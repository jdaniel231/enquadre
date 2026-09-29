class CreateAbsencePolicies < ActiveRecord::Migration[8.1]
  def change
    create_table :absence_policies do |t|
      t.references :account, null: false, foreign_key: true
      t.boolean :charge_absent_late, null: false, default: true
      t.boolean :charge_absent_notified, null: false, default: false

      t.timestamps
    end
  end
end
