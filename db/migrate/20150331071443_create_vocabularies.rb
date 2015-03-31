class CreateVocabularies < ActiveRecord::Migration
  def change
    create_table :vocabularies do |t|
      t.string :name
      t.text :definition
      t.text :example
      t.string :url
      t.boolean :confirmed

      t.timestamps null: false
    end
  end
end
