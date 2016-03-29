class CreateProduct < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string  :name
      t.text    :desc
      t.string  :price
      t.string  :image
      t.boolean :sold
      t.boolean :actif
      t.integer :order
      t.timestamps
    end
  end
end
