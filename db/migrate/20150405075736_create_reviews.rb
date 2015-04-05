class CreateReviews < ActiveRecord::Migration
  def up
    create_table :reviews do |t|
      t.belongs_to :vocabulary, index: true

      t.timestamps null: false
    end
  end

  def down
    drop_table :reviews
  end
end
