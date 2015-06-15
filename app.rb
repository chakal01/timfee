# myapp.rb
require 'bundler'
Bundler.require(:default)

require 'sinatra'
require 'sinatra/base'
require 'sinatra/activerecord'
require 'sinatra/namespace'
require 'sinatra/assetpack'

require './config/environments'
require './models/post'
require './helpers/auth_helper'

class App < Sinatra::Base
  register Sinatra::AssetPack
  register Sinatra::Namespace
  
  set :root, File.dirname(__FILE__)

  assets do
    js :application, [
      '/js/jquery-1.11.2.min.js',
      '/js/app.js'
    ]

    css :application, [
      '/css/app.css'
     ]
    serve '/images', from: 'app/images' 

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
    # @posts = Post.all
    @posts = ["first", "P3060006", "P3060007", "P3060010", 
        "P3060012", "P4030001", "P4030002", "P4030003"].each_with_index.map { |icon,i| {icon: "#{icon}.jpg", id: i} }
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

    get '/new' do
      @post = Post.new
      @form_url = "/admin/new"
      @titre = "Nouveau post"
      erb :edit
    end

    post '/new' do
      Post.create(titre: params[:titre], content: params[:content], date: params[:date], 
        icon: params[:icon], actif: params[:actif], color: params[:color],views: 0)
      redirect '/admin'
    end

    get '/:id' do
      @post = Post.find(params[:id])
      @form_url = "/admin/#{params[:id]}"
      @titre = "Editer #{@post.titre}"
      erb :edit
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
        icon: params[:icon], actif: params[:actif], color: params[:color]
        ) unless @post.nil?
      redirect '/admin'
    end

  end

end