require 'bundler'
Bundler.require(:default)

require 'yaml'
require './models/post'
require './models/image'
require './models/notification'
require './models/product'
require './helpers/auth_helper'
require './helpers/view_helper'
require './helpers/captcha_helper'
require './helpers/mailer_helper'
require 'securerandom'
require 'logger'
require 'sinatra/assetpack'
require 'sinatra/flash'
require 'sinatra/cookies'
require 'sinatra/reloader'


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
  include CaptchaHelper
  include MailerHelper
  enable :sessions
  register Sinatra::Flash
  helpers Sinatra::Cookies

  config = YAML.load_file('./config/application.yml')

  if config["file_logger"]
    ::Logger.class_eval { alias :write :'<<' }
    access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)),'log','access.log')
    access_logger = ::Logger.new(access_log)
    error_logger = ::File.new(::File.join(::File.dirname(::File.expand_path(__FILE__)),'log','error.log'),"a+")
    error_logger.sync = true
  end

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
    js :contact, ['/js/contact.js']

    js :edit, ['/markitup/jquery.markitup.js', '/markitup/sets/html/set.js', '/js/edit.js', '/js/jquery.Jcrop.min.js']
    css :edit, ['/css/jquery.Jcrop.min.css', '/markitup/skins/simple/style.css', '/markitup/sets/html/style.css']

    js :page, ['/js/lightgallery.js', '/js/page.js']
    css :page, ['/css/lightgallery.css']

    js :products, ['/js/products.js']

    js_compression :jsmin
    css_compression :sass
  end

  configure do
    if config["file_logger"]
      use ::Rack::CommonLogger, access_logger
    end
  end

  configure :development do
    register Sinatra::Reloader
  end

  before do
    @title = "Copeaux d'aronde"
    if config["file_logger"]
      env["rack.errors"] = error_logger
    end
  end

  def h(text)
    Rack::Utils.unescape(text) rescue text
  end

  get '/' do
    @posts = Post.where(actif: true).order(:order)
    @meta_keywords = "sur mesure multimatériaux mobilier ébénisterie écolo bois naturel sain finitions qualité artisanat d'art"
    @meta_description = "Timothée DELAY, ébéniste d'art à Ceyzériat, dans l'Ain (01). Mobilier unique, multimatériaux, d'intérieur et d'extérieur. Fabrication sur mesure."
    erb :main
  end

  get '/contact' do
    cookies[:title] = "Demande de renseignements: #{params[:title]}"
    redirect '/aab0f' #4b901'
  end

  # ============ admin section


  namespace '/admin' do
    include AuthHelper

    before do
      @title = "Admin Copeaux d'aronde"
      @is_admin = "_admin"
      protected!
    end

    get '' do
      @posts = Post.all.order(:order)
      erb :admin
    end

    get '/product' do
      @products = Product.all.order(:order)
      erb :products
    end

    get '/product/new' do
      @product = Product.new
      @action = "/admin/product/new"
      erb :product_edit
    end

    post '/product/new' do
      cookies[:name] = params[:name]
      cookies[:desc] = params[:desc]
      cookies[:more_desc] = params[:more_desc]
      cookies[:state] = params[:state]

      missing_fields = []
      missing_fields << "Nom" if params[:name].nil? or params[:name]==""
      missing_fields << "Description" if params[:desc].nil? or params[:desc]==""
      missing_fields << "Prix" if params[:more_desc].nil? or params[:more_desc]==""
      missing_fields << "State" if params[:state].nil? or params[:state]==""
      missing_fields << "Image" if params[:image].nil?

      unless missing_fields.empty?
        flash[:error] = "Données manquantes : "+missing_fields.join(', ')
        redirect '/admin/product/new'

      else
        cookies[:desc], cookies[:more_desc], cookies[:name] = nil, nil, nil
        pa = params.slice("name", "desc", "more_desc", "image")
        @product = Product.create(pa)

        format = params["image"][:filename].split('.')[1].downcase
        @product.update_attributes({image: "img_#{@product.id}.#{format}"})

        File.open("./app/images/posts/vente/#{@product.image}", "wb") do |f|
          f.write(params["image"][:tempfile].read)
        end

        i = Magick::Image.read("./app/images/posts/vente/#{@product.image}").first        
        i.resize_to_fit(800,800).write("./app/images/posts/vente/#{@product.image}")

        flash[:success] = "Produit créé !"
        redirect '/admin/product'
      end
    end

    post '/product/order' do
      params[:list].each_with_index do |id, index|
        product = Product.find_by(id: id)
        product.order = index
        product.save
      end
      halt 200
    end

    get '/product/preview' do
      @products = Product.order(:order)
      @explications = "Sur ce preview, tout les produits sont affichés, qu'ils soient actifs ou non."
      @return_button = true
      erb :vente
    end

    get '/product/:id' do
      @product = Product.find(params[:id])
      @edition = true
      @action = "/admin/product/#{params[:id]}"
      redirect '/admin/product' if @product.nil?
      erb :product_edit
    end

    post '/product/:id' do
      pa = params.slice("name", "desc", "more_desc", "state")
      Product.find(params[:id]).update_attributes(pa)
      redirect '/admin/product'
    end

    get '/product/:id/delete' do
      Product.where(id: params[:id]).destroy_all
      redirect '/admin/product'
    end

    get '/:id/toggle_actif' do
      @product = Product.find(params[:id])
      @product.actif = !@product.actif
      @product.save
      halt 200
    end

    get '/:id/toggle_sold' do
      @product = Product.find(params[:id])
      @product.sold = !@product.sold
      @product.save
      halt 200
    end

    get '/notifications' do
      @notifications = Notification.order(:created_at).reverse
      erb :notifications
    end

    get '/notification/:id/delete' do
      Notification.where(id: params[:id]).delete_all
      redirect '/admin/notifications'
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
      @tab = params[:tab]||"home"
      @form_url = "/admin/#{params[:id]}"
      @titre = "Editer #{@post.titre}"
      erb :edit
    end

    get '/vente/show' do
      @products = Product.where(actif: true).order(:order)
      @explications = "Ce preview correspond à la page telle que vue par les visiteurs du site."
      @return_button = true
      erb :vente
    end

    get '/:id/show' do
      @post = Post.find_by(sha1: params[:id])
      redirect '/admin' if @post.nil?
      @return_button = true
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

      order_base = post.images.length
      params['myfile'].each_with_index do |file, index|


        format = file[:filename].split('.')[1].downcase
        img = Image.create(
          titre: params[:titre],
          post_id: post.id,
          file_icon: SecureRandom.hex[0..7]+'.'+format,
          file_preview: SecureRandom.hex[0..7]+'.'+format,
          file_normal: SecureRandom.hex[0..7]+'.'+format,
          order: order_base+index
        )
        File.open("./app/images/posts/#{post.folder_hash}/#{img.file_normal}", "wb") do |f|
          f.write(file[:tempfile].read)
        end

        i = Magick::Image.read("./app/images/posts/#{post.folder_hash}/#{img.file_normal}").first
        width, height = i.columns, i.rows
        
        if width > 1024 || height > 1024
          i.resize_to_fit(1024,1024).write("./app/images/posts/#{post.folder_hash}/#{img.file_normal}")
        end

        if width > 450 || height > 450
          i.resize_to_fit(450,450).write("./app/images/posts/#{post.folder_hash}/#{img.file_preview}")
        else
          i.write("./app/images/posts/#{post.folder_hash}/#{img.file_preview}")          
        end

        if width > 150 || height > 150
          i.resize_to_fill(150,150).write("./app/images/posts/#{post.folder_hash}/#{img.file_icon}")
        else
          i.write("./app/images/posts/#{post.folder_hash}/#{img.file_icon}")
        end

      end
      redirect "/admin/#{params[:id]}?tab=galerie"
    end

    post '/icon' do
      dx, dy, width, height = params[:dx].to_i, params[:dy].to_i, params[:width].to_i, params[:height].to_i
      post = Post.find_by(sha1: params[:post_id])
      img = Image.find_by(id: params[:img_id].to_i)
      File.delete("./app/images/posts/#{post.folder_hash}/#{img.file_icon}")
      img.file_icon = SecureRandom.hex[0..7]+'.'+img.file_preview.split('.')[1].downcase
      img.save

      i = Magick::Image.read("./app/images/posts/#{post.folder_hash}/#{img.file_preview}").first
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
      # Reorder images
      @img.post.images.order(:order).map{|img| img.id}.each_with_index do |id, index|
        img = Image.find_by(id: id)
        img.order = index
        img.save
      end
      redirect "/admin/#{@img.post.sha1}?tab=galerie"
    end

    post '/order' do
      params[:list].each_with_index do |sha1, index|
        post = Post.find_by(sha1: sha1)
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
      redir = params[:redirect].nil? ? "" : "?tab=#{params[:redirect]}"
      redirect "/admin/#{@post.sha1}#{redir}"
    end

  end

  # End of ADMIN section

  post '/contact' do
    cookies[:email] = params[:email]
    cookies[:confirmEmail] = params[:confirmEmail]
    cookies[:title] = params[:title]
    cookies[:content] = params[:content]

    errors = []
    errors << "Emails non compatibles" if params[:email]!=params[:confirmEmail]
    errors << "Veuillez écrire un message" if params[:content].nil? or params[:content]==""
    errors << "Code de sécurité erroné" unless captcha_pass?
    
    unless errors.empty?
      errors << "Veuillez retaper le code de sécurité" unless errors.include? "Code de sécurité erroné"
      flash[:error] = errors.join(', ')
    else
      send_mail(params[:email], params[:title], params[:content])
      cookies[:title], cookies[:content] = nil, nil
      Notification.create(email: params[:email], title: params[:title], content: params[:content] )
      flash[:success] = "Votre message a bien été envoyé à Timothée Delay, je vous recontacterai au plus vite."
    end
    redirect params[:page]
  end

  get '/vente' do
    @products = Product.where(actif: true).order(:order)
    @return_button = false
    erb :vente
  end

  get '/:id' do
    @post = Post.find_by(sha1: params[:id])
    redirect '/' if @post.nil? or !@post.actif
    list = Post.all.where(actif: true).order(:order).pluck(:sha1)
    @next = list.index(@post.sha1)==list.length-1 ? nil : list[list.index(@post.sha1)+1]
    @previous = list.index(@post.sha1)==0 ? nil : list[list.index(@post.sha1)-1]
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