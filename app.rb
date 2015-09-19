require 'bundler'
Bundler.require(:default)

require 'yaml'
require './models/post'
require './models/image'
require './helpers/auth_helper'
require './helpers/view_helper'
require 'securerandom'
require 'logger'
require 'sinatra/assetpack'

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
  include ViewHelper
  
  config = YAML.load_file('./config/application.yml')

  # if config["file_logger"]
  #   ::Logger.class_eval { alias :write :'<<' }
  #   access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)),'log','access.log')
  #   access_logger = ::Logger.new(access_log)
  #   error_logger = ::File.new(::File.join(::File.dirname(::File.expand_path(__FILE__)),'log','error.log'),"a+")
  #   error_logger.sync = true
  # end

  set :root, File.dirname(__FILE__)

  assets do
    serve '/images', from: 'app/images'
    serve '/css', from: 'app/css'
    serve '/js', from: 'app/js'
    serve '/fonts', from: 'app/fonts'
    serve '/markitup', from: 'app/markitup'

    js :layout, ['/js/jquery-1.11.2.min.js', '/js/bootstrap.min.js']
    css :layout, ['/css/bootstrap.min.css', '/css/app.css']

    js :admin, ['/js/admin.js']

    js :edit, ['/markitup/jquery.markitup.js', '/markitup/sets/html/set.js', '/js/edit.js', '/js/jquery.Jcrop.min.js']
    css :edit, ['/css/jquery.Jcrop.min.css', '/markitup/skins/simple/style.css', '/markitup/sets/html/style.css']

    js :page, ['/js/lightgallery.js', '/js/page.js']
    css :page, ['/css/lightgallery.css']

    js_compression :jsmin
    css_compression :sass
  end

  # configure do
  #   if config["file_logger"]
  #     use ::Rack::CommonLogger, access_logger
  #   end
  # end

  # before do
  #   @title = "Copeaux d'aronde"
  #   if config["file_logger"]
  #     env["rack.errors"] = error_logger
  #   end
  # end

  def h(text)
    Rack::Utils.unescape(text)
  end

  get '/' do
    @posts = Post.where(actif: true).order(:order)
    @meta_keywords = "sur mesure multimatériaux mobilier ébénisterie écolo bois naturel sain finitions qualité artisanat d'art"
    @meta_description = "Mobilier multimatériaux, d'intérieur et d'extérieur, par Timothée Delay."
    erb :main
  end

  


  # ============ admin section


  namespace '/admin' do
    include AuthHelper

    before do
      protected!
    end

    get '' do
      @posts = Post.all.order(:order)
      erb :admin
    end

    post '/new' do
      post = Post.create(titre: params[:titre])
      redirect "/admin/#{post.sha1}"
    end

    post '/' do
      Post.create(titre: params[:titre], content: params[:content], date: params[:date], 
        icon_id: params[:icon], actif: params[:actif], color: params[:color],views: 0)
      redirect '/admin'
    end

    get '/:id' do
      @post = Post.find_by(sha1: params[:id])
      redirect '/' if @post.nil?
      @form_url = "/admin/#{params[:id]}"
      @titre = "Editer #{@post.titre}"
      erb :edit
    end

    get '/:id/show' do
      @post = Post.find_by(sha1: params[:id])
      redirect '/admin' if @post.nil?
      erb :page
    end

    get '/:id/toggle' do
      @post = Post.find_by(sha1: params[:id])
      @post.actif = !@post.actif
      @post.save
      halt 200
    end

    post "/upload" do
      post = Post.find_by(sha1: params[:id])
      format = params['myfile'][:filename].split('.')[1].downcase
      img = Image.create(
        titre: params[:titre],
        post_id: post.id,
        file_icon: SecureRandom.hex[0..7]+'.'+format,
        file_preview: SecureRandom.hex[0..7]+'.'+format,
        file_normal: SecureRandom.hex[0..7]+'.'+format
      )
      File.open("./app/images/posts/#{post.folder_hash}/#{img.file_normal}", "wb") do |f|
        f.write(params['myfile'][:tempfile].read)
      end

      i = Magick::Image.read("./app/images/posts/#{post.folder_hash}/#{img.file_normal}").first
      i.resize_to_fill(150,150).write("./app/images/posts/#{post.folder_hash}/#{img.file_icon}")
      i.resize_to_fill(450,450).write("./app/images/posts/#{post.folder_hash}/#{img.file_preview}")

      redirect '/admin/'+params[:id]
    end

    post '/icon' do
      dx, dy, width, height = params[:dx].to_i, params[:dy].to_i, params[:width].to_i, params[:height].to_i
      post = Post.find_by(sha1: params[:post_id])
      img = Image.find_by(id: params[:img_id].to_i)
      File.delete("./app/images/posts/#{post.folder_hash}/#{img.file_icon}")
      img.file_icon = SecureRandom.hex[0..7]+'.'+img.file_normal.split('.')[1].downcase
      img.save

      i = Magick::Image.read("./app/images/posts/#{post.folder_hash}/#{img.file_normal}").first
      i.crop(dx, dy, width, height).resize_to_fill(150,150).write("./app/images/posts/#{post.folder_hash}/#{img.file_icon}")

      post.icon_id = img.id
      post.save

      redirect "/admin/#{post.sha1}"
    end



    get '/post/:id/delete' do
      @post = Post.find_by(sha1: params[:id])
      @post.destroy unless @post.nil?
      redirect '/admin'
    end

    post '/img/:id' do
      @img = Image.find_by(id: params[:id])
      halt 400 if @img.nil?
      @img.titre = params[:titre]
      @img.save
      halt 200
    end

    get '/img/:id/delete' do
      @img = Image.find_by(id: params[:id])
      redirect '/admin' if @img.nil?
      if @img.post.icon_id == @img.id
        @img.post.icon_id = nil
        @img.post.save
      end
      @img.destroy
      redirect "/admin/#{@img.post.id}"
    end

    post '/order' do
      params[:list].each_with_index do |sha1, index|
        post = Post.find_by(sha1: sha1)
        post.order = index
        post.save
      end
      halt 200
    end

    post '/orderimg' do
      puts params[:list]
      params[:list].each_with_index do |id, index|
        post = Image.find_by(id: id)
        post.order = index
        post.save
      end
      halt 200
    end

    post '/:id' do
      @post = Post.find_by(sha1: params[:id])
      redirect '/admin' if @post.nil?
      @post.titre = params[:titre] if params[:titre]
      @post.content = params[:content] if params[:content]
      @post.meta_keywords = params[:meta_keywords] if params[:meta_keywords]
      @post.save
      redirect "/admin/#{@post.sha1}"
    end

  end

# End of ADMIN section

  get '/:id' do
    @post = Post.find_by(sha1: params[:id])
    redirect '/' if @post.nil? or !@post.actif

    @next = @post.order==Post.count-1 ? nil : Post.find_by(order: @post.order+1).sha1
    @previous = @post.order==0 ? nil : Post.find_by(order: @post.order-1).sha1
    @meta_keywords = @post.meta_keywords

    if @post.views.nil?
      @post.views = 0
    else
      @post.views += 1
    end
    @post.save
    erb :page
  end


end