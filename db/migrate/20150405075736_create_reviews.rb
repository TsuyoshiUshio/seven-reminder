class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :vocabulary_id

      t.timestamps null: false
    end
  end
end
