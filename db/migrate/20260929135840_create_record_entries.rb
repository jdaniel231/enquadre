class CreateRecordEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :record_entries do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :appointment, null: true, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
