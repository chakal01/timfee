class CreateNotification < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :email
      t.string :title
      t.string :content
      t.boolean :read
      t.timestamps
    end
  end
end
