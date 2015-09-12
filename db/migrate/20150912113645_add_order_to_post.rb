require './app.rb'
require 'securerandom'

class AddOrderToPost < ActiveRecord::Migration
  def up
    add_column :posts, :order, :integer
    add_column :posts, :sha1,  :text
    Post.all.each_with_index do |post, index|
        post.update_attributes({sha1: SecureRandom.hex[0..4], order: index})
    end
  end

  def down
    remove_column :posts, :order, :integer
    remove_column :posts, :sha1,  :text
  end

end
