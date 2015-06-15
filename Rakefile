require 'yaml'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
db = YAML.load_file('./config/database.yml')["development"]

  ActiveRecord::Base.establish_connection(
      adapter: 'postgresql',
      host: db["host"],
      username: db["username"],
      password: db["password"],
      database: db["database"],
      encoding: db["encoding"]
  )