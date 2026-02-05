class CreateInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :inquiries do |t|
      t.references :user, null: false, foreign_key: true
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end
