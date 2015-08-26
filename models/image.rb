class Image < ActiveRecord::Base
	belongs_to :post
	before_destroy :delete_files

	private
		def delete_files
			File.delete("./app/images/#{self.post.folder_hash}/#{self.file_icon}")
			File.delete("./app/images/#{self.post.folder_hash}/#{self.file_preview}")
			File.delete("./app/images/#{self.post.folder_hash}/#{self.file_normal}")
		end
end