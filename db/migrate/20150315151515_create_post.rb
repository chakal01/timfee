class CreatePost < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :titre
      t.string :content
      t.datetime :date
      t.boolean :actif
      t.timestamps
    end
  end
end
