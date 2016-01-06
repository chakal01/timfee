require 'yaml'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require './helpers/mailer_helper.rb'

db = YAML.load_file('./config/database.yml')["development"]

  ActiveRecord::Base.establish_connection(
      adapter: db["adapter"],
      host: db["host"],
      username: db["username"],
      password: db["password"],
      database: db["database"],
      encoding: db["encoding"]
  )


require './lib/zip_file_generator'
require 'zip'

desc "DB backup and Zip the current folder into an zip archive. Send both files by email."
task :backup do

  t = Time.now.to_i
  db_file = "../db_#{t}.sql"
  zip_file = "../timfee_#{t}.zip"

  puts "Starting backup"
  puts "pg_dump -U #{db["username"]} -d #{db['database']} > #{db_file}"
  system "pg_dump -U #{db["username"]} -d #{db['database']} > #{db_file}"
  puts "DB backup done."

  project_folder = "../timfee"  
  zf = ZipFileGenerator.new(project_folder, zip_file)
  zf.write()
  puts "Zip backup done"

  MailerHelper.send_backup_mail("/home/mint/Documents/db_#{t}.sql", "/home/mint/Documents/timfee_#{t}.zip")

  # delete db_backup and zip
  FileUtils.rm "/home/mint/Documents/db_#{t}.sql"
  FileUtils.rm "/home/mint/Documents/timfee_#{t}.zip"
  puts "Files deleted."

end
