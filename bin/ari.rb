require 'rubygems'
require 'sinatra'
require File.join(File.dirname(__FILE__), "..", "lib", "ari")

RAILS_ENV.replace("development") if defined?(RAILS_ENV)


configure do
  Log = Logger.new("sinatra.log") # or log/development.log, whichever you prefer
  Log.level  = Logger::INFO

  Ari.boot_active_record
  Ari.load_ari_members

 # set :root, "/opt/local/lib/ruby/gems/1.8/gems/ari-1.0.0"
  set :run, true
end

get '/' do
  haml :index
end

get '/show/:class/:id' do
  @obj = get_class(params[:class]).find(params[:id])
  haml :show, :layout => false
end

get '/search' do
  klass_name, q = params[:q].split(/\s+/)
  @klass = eval(klass_name)
  cols = search_columns(@klass)
  @objs = @klass.all(:conditions => [where_clause(cols, q)] + cols.collect {"%#{q}%"}, :order => cols.first)
  haml :list, :layout => false
end

get '/list/:class/:id/:assoc' do
  klass = eval(params[:class])
  @obj = klass.find(params[:id])
  @objs = @obj.send(params[:assoc])
  @cols = search_columns(klass)
  haml :list, :layout => false
end

get '/classes' do
  #"['" + @@classes.join("', '") + "']"
  "['Provider', 'Zone']"
end

def where_clause(search_columns, q)
  clause = ""
  search_columns.each_with_index do |col, i|
    clause << " OR " unless i == 0
    clause << "#{col} LIKE ?"
  end
  clause
end

def search_columns(klass)
  cols = klass.columns.select do |col|
    if klass.explorer_columns.include?(col.name) && [:text, :string].include?(col.type)
      next col.name
    end
    false
  end

  cols.collect {|col| col.name}
end
