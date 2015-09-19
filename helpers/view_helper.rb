module ViewHelper

  def get_content(post)
    images = {}
    post.images.order(:order).each do |img|
      images[(img.order+1).to_s] = "<p class='center'>
        <a class='item' href='/images/posts/#{post.folder_hash}/#{img.file_normal}' data-sub-html='#{img.titre}'>
        <img src='/images/posts/#{post.folder_hash}/#{img.file_preview}' alt='#{img.titre}'/>
        </a>
        </p>"
    end
    return post.content.gsub(/!#([0-9]*)/) { images["#{$1}"] }

  end
  
end