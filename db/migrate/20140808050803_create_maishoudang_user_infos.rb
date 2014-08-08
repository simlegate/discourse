class CreateMaishoudangUserInfos < ActiveRecord::Migration
  def change
    create_table :maishoudang_user_infos do |t|
      t.integer :user_id, null: false
      t.string :username, null: false
      t.string :email, null: false
      t.string :username_pinyin
      t.string :avatar_url
      t.integer :maishoudang_user_id, null: false

      t.timestamps
    end

    add_index :maishoudang_user_infos, [:maishoudang_user_id], unique: true
    add_index :maishoudang_user_infos, [:user_id], unique: true
  end
end
