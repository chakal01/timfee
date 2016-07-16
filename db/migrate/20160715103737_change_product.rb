class ChangeProduct < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.text    :more_desc
      t.remove  :price
    end
  end
end
