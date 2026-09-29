class CreatePatients < ActiveRecord::Migration[8.1]
  def change
    create_table :patients do |t|
      t.references :account, null: false, foreign_key: true
      t.string :full_name
      t.string :cpf
      t.string :phone
      t.string :email
      t.date :date_of_birth
      t.text :notes

      t.timestamps
    end
  end
end
