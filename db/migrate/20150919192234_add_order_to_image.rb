require './app.rb'

class AddOrderToImage < ActiveRecord::Migration
  def up
    add_column :images, :order, :integer
    Post.all.each do |post|
      post.images.each_with_index do |image, index|
        image.update_attributes({order: index})
      end
    end
  end

  def down
    remove_column :posts, :order, :integer
  end

end
