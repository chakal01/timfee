# myapp.rb
require 'bundler'
Bundler.require(:default)

# require 'sinatra'
# require 'sinatra/activerecord'
# require 'sinatra/namespace'
# require 'sinatra/assetpack'
require './config/environments'
require './models/post'
# require 'haml'

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

get '/' do
  # @posts = Post.all
  @posts = ["first", "P3060006", "P3060007", "P3060010", 
      "P3060012", "P4030001", "P4030002", "P4030003"].each_with_index.map { |icon,i| {icon: "#{icon}.jpg", id: i} }
  erb :main
end


# get '/page/:n' do
#   page = params[:n].to_i <= 0 ? 0 : params[:n].to_i
#   redirect '/' if page==0
#   @articles = Article.all.order("date desc").limit(3).offset(page*3)
#   if @articles.empty?
#     redirect '/'
#   else
    
#     is_next = Article.all.order("date desc").limit(1).offset(page*3+1).empty?
#     @url_next = "/page/#{page+1}" unless is_next

#     @url_previous = page > 1 ? "/page/#{page-1}" : "/"
#   end
#   haml :main
# end

get '/post/:id' do
  # @post = Post.find(params[:id])
  # redirect '/' if @post.nil?
  @titre = "Yopla ! "
  erb :page
end


# ============ admin section

helpers do

  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
  end

  def h(text)
    Rack::Utils.unescape(text)
  end
end

# namespace '/admin' do
#   before  { protected! }

#   get '' do
#     @articles = Article.all.order("date desc")
#     haml :admin
#   end

#   get '/new' do
#     haml :new
#   end

#   post '/new' do
#     a = Article.create(title: params[:title], content: params[:content], date: Time.now, loads: 0)
#     redirect '/admin'
#   end

#   get '/edit/:key' do
#     @article = Article.find_by(key: params[:key])
#     haml :edit
#   end

#   post '/edit/:key' do
#     @article = Article.find_by(key: params[:key])
#     @article.update_attributes(title: params[:title], content: params[:content]) unless @article.nil?
#     redirect '/admin'
#   end

# end
#  