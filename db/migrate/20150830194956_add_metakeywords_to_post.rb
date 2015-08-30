class AddMetakeywordsToPost < ActiveRecord::Migration
  def change
    add_column :posts, :meta_keywords, :string
  end
end
