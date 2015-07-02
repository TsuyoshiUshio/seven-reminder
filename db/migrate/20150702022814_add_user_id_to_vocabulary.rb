class AddUserIdToVocabulary < ActiveRecord::Migration
  def up
      add_column :vocabularies, :user_id, :integer, index: true
  end
  def down
      remove_column :vocabularies, :user_id
  end
end
