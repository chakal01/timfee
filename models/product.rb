class Product < ActiveRecord::Base
  before_create :default_values
  before_destroy :delete_files

  private
    def default_values
      self.actif = 0
      self.sold = 0
      self.order = Product.count
    end

    def delete_files
      begin File.delete("./app/images/posts/vente/#{self.image}");rescue; end
    end
end
