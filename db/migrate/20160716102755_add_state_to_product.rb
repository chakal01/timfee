class AddStateToProduct < ActiveRecord::Migration
  def change
    change_table :products do |t|
      t.text    :state
    end
  end
end
