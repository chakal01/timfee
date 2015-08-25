require 'bundler'
Bundler.require(:default)

require 'yaml'
require './models/post'
require './models/image'
require './helpers/auth_helper'
require 'securerandom'

db = YAML.load_file('./config/database.yml')["development"]

  ActiveRecord::Base.establish_connection(
      adapter: db["adapter"],
      host: db["host"],
      username: db["username"],
      password: db["password"],
      database: db["database"],
      encoding: db["encoding"]
  )

class App < Sinatra::Base
  register Sinatra::AssetPack
  register Sinatra::Namespace
  
  set :root, File.dirname(__FILE__)

  assets do
    serve '/images', from: 'app/images' 
    serve '/css', from: 'app/css'
    serve '/js', from: 'app/js'
    js_compression :jsmin
    css_compression :sass
  end


  before do
    @title = "Petites pensées ridicules..."
  end

  def h(text)
    Rack::Utils.unescape(text)
  end

  get '/' do
    @posts = Post.all
    erb :main
  end

  get '/post/:id' do
    @post = Post.find(params[:id])
    redirect '/' if @post.nil?
    erb :page
  end


  # ============ admin section


  namespace '/admin' do
    include AuthHelper

    before do
      protected!
    end

    get '' do
      @posts = Post.all
      erb :admin
    end

    post '/new' do
      post = Post.create(titre: params[:titre])
      redirect "/admin/#{post.id}"
    end

    post '/' do
      Post.create(titre: params[:titre], content: params[:content], date: params[:date], 
        icon_id: params[:icon], actif: params[:actif], color: params[:color],views: 0)
      redirect '/admin'
    end

    get '/:id' do
      @post = Post.find(params[:id])
      @form_url = "/admin/#{params[:id]}"
      @titre = "Editer #{@post.titre}"
      erb :edit
    end

    post "/upload" do
      post = Post.find(params[:id])
      format = params['myfile'][:filename].split('.')[1].downcase
      img = Image.create(
        titre: params[:titre],
        post_id: post.id,
        file_icon: SecureRandom.hex[0..7]+'.'+format,
        file_preview: SecureRandom.hex[0..7]+'.'+format,
        file_normal: SecureRandom.hex[0..7]+'.'+format
      )
      File.open("./app/images/#{post.folder_hash}/#{img.file_normal}", "wb") do |f|
        f.write(params['myfile'][:tempfile].read)
      end

      i = Magick::Image.read("./app/images/#{post.folder_hash}/#{img.file_normal}").first
      i.resize_to_fill(150,150).write("./app/images/#{post.folder_hash}/#{img.file_icon}")
      i.resize_to_fill(450,450).write("./app/images/#{post.folder_hash}/#{img.file_preview}")

      redirect '/admin/'+params[:id]
    end

    post '/icon' do
      puts params
      dx, dy, width, height = params[:dx].to_i, params[:dy].to_i, params[:width].to_i, params[:height].to_i
      post = Post.find(params[:post_id].to_i)
      img = Image.find(params[:img_id].to_i)
      i = Magick::Image.read("./app/images/#{post.folder_hash}/#{img.file_normal}").first
      i.crop(dx, dy, width, height).resize_to_fill(150,150).write("./app/images/#{post.folder_hash}/#{img.file_icon}")

      post.icon = img
      post.save
      redirect "/admin/#{post.id}"

    end



    get '/:id/delete' do
      @post = Post.find(params[:id])
      @post.delete unless @post.nil?
      redirect '/admin'
    end

    post '/:id' do
      @post = Post.find(params[:id])
      @post.update_attributes(
        titre: params[:titre], content: params[:content], date: params[:date], 
        icon_id: params[:icon], actif: params[:actif], color: params[:color]
        ) unless @post.nil?
      redirect '/admin'
    end

  end

end