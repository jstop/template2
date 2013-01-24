require 'rubygems'
require 'bundler'
require 'mongo_mapper'
require 'sinatra'
require 'haml'
require 'json'
#require 'rack-flash'
require 'sinatra-authentication'
#require 'omniauth'
#require 'omniauth-twitter'
require 'ri_cal'
require 'mm-voteable'
require 'action_mailer'

configure :development do
  set :public_folder, '../ui/public'
  set :views, '../ui/views'
  MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
  MongoMapper.database = "development_db"
  ActionMailer::Base.smtp_settings = {
            :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'localhost',
            :user_name            => 'josh.stein107@gmail.com',
            :password             => 'zaq12wsX',
            :authentication       => 'plain',
            :enable_starttls_auto => true  
  }
  ActionMailer::Base.view_paths = '../ui/views'
end

configure :production do 
  set :public_folder, '../ui/build'
  set :views, '../ui/build/views'
end

use Rack::Session::Cookie, :secret => 'A1 sauce 1s so good you should use 1t on a11 yr st34ksssss'
#use Rack::Flash
require './main.rb'
run App.new
