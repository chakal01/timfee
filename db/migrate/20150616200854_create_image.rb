class CreateImage < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :titre
      t.string :file
      t.integer :post_id
      t.timestamps
    end
    add_column :posts, :folder_hash, :string
    remove_column :posts, :icon
    add_column :posts, :icon_id, :integer
    

  end
end
