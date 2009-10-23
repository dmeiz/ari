require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), "..", "lib", "ari")

RAILS_ENV.replace("development") if defined?(RAILS_ENV)


configure do
  Log = Logger.new("sinatra.log") # or log/development.log, whichever you prefer
  Log.level  = Logger::INFO

  Ari.boot_active_record
  Ari.load_display_atts

  set :root, File.join(File.dirname(__FILE__), ".." )
  set :run, true
end

get '/' do
  @database_config = ActiveRecord::Base.connection.config
  haml :index
end

get '/show/:class/:id' do
  @obj = Ari.get_class(params[:class]).find(params[:id])
  haml :show, :layout => false
end

get '/search' do
  class_name, q = params[:q].split(/\s+/)
  @class = Ari.get_class(class_name)
  @objs = @class.find_all_for_ari(q)
  haml :list, :layout => false
end

get '/list/:class/:id/:assoc' do
  @class = Ari.get_class(params[:class])
  @obj = @class.find(params[:id])
  @objs = @obj.send(params[:assoc])
  @class = @objs.first.class
  haml :list, :layout => false
end

get '/classes' do
  "['" + ActiveRecord::Base.available_classes.join("', '") + "']"
end
