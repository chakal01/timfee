module ViewHelper

  def get_content(post)
    images = {}
    post.images.order(:order).each do |img|
      images[(img.order+1).to_s] = "
        <a class='item' href='/images/posts/#{post.folder_hash}/#{img.file_normal}' data-sub-html='#{img.titre}'>
        <img src='/images/posts/#{post.folder_hash}/#{img.file_preview}' alt='#{img.titre}'/>
        </a>"
    end

    return post.content.gsub(/!#contact/, '').gsub(/!#([0-9]+)/) { get_p_image(images["#{$1}"]) }.gsub(/!#\(([0-9]+)\+([0-9]+)\)/) { get_p_images(images["#{$1}"], images["#{$2}"]) }
  end

  def get_p_image(a_tag)
    "<p class='center'>#{a_tag}</p>"
  end

  def get_p_images(a_tag1, a_tag2 )
    "<p class='center'><p class='half'> #{a_tag1}</p><p class='half'>#{a_tag2}</p></p>"
  end
  
end