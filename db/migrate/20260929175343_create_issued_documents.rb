class CreateIssuedDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :issued_documents do |t|
      t.references :patient, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :kind, null: false
      t.text :content, null: false
      t.text :rendered_html, null: false
      t.integer :amount_cents

      t.timestamps
    end
  end
end
