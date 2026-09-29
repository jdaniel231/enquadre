class CreateProfessionalProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :professional_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.string :crp

      t.timestamps
    end
  end
end
