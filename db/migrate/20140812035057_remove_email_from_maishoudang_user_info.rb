class RemoveEmailFromMaishoudangUserInfo < ActiveRecord::Migration
  def change
    remove_column :maishoudang_user_infos, :email, :string
  end
end
