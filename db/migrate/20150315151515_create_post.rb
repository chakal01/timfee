class CreatePost < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :titre
      t.string :content
      t.string :date
      t.boolean :actif
      t.string :icon
      t.string :color
      t.integer :views
      t.timestamps
    end
  end
end
