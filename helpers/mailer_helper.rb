require 'yaml'
require 'mail'

config_mail, mailer = YAML.load_file('./config/mailer.yml'), {}
config_mail.each{|k,v| mailer[k.to_sym] = v}
Mail.defaults do
  delivery_method :smtp,  mailer
end

#
# helper module to send mail
#
module MailerHelper

  def send_mail(email, title, content)
    config = YAML.load_file("./config/application.yml")
    begin
      mail = Mail.new do
        from config["email"]["from"]
        to config["email"]["to"].join(";")
        subject config["email"]["subject"]
        body "Salut ! Une demande de contact a été posté sur http://copeauxdaronde.fr !\n\n\nPar: #{email}\nObjet: #{title}\n\n#{content}"
      end
      mail.deliver
    rescue => e
      File.open('log/mailer.log', 'a+') do |f|
        f.write "[#{Time.now}] #{e.message}\n#{e.backtrace.join("\n")}"
      end
    end
  end

  def self.send_backup_mail(db_file, zip_file)
    config = YAML.load_file("./config/application.yml")
    begin
      mail = Mail.new do
        from config["email"]["from"]
        to config["email"]["to"].join(";")
        subject "Backup"
        body "Salut ! Voici un petit backup. Le dossier du projet et la DB. Nice, isn't it ? N'est-il pas ? :)"
        add_file :filename => 'backup.sql', :content => File.read(db_file)
        add_file :filename => 'backup.zip', :content => File.read(zip_file)
      end
      mail.deliver
    rescue => e
      File.open('log/mailer.log', 'a+') do |f|
        f.write "[#{Time.now}] #{e.message}\n#{e.backtrace.join("\n")}"
      end
    end
  end

end