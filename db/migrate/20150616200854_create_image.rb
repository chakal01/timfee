class CreateImage < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :titre
      t.string :file_icon
      t.string :file_preview
      t.string :file_normal
      t.integer :post_id
      t.timestamps
    end
    add_column :posts, :folder_hash, :string
    remove_column :posts, :icon, :string
    add_column :posts, :icon_id, :integer
    

  end
end
