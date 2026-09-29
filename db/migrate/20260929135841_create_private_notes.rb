class CreatePrivateNotes < ActiveRecord::Migration[8.1]
  def change
    create_table :private_notes do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
