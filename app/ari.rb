$: << "app/models"
require 'rubygems'
require 'sinatra'

RAILS_ENV.replace("development") if defined?(RAILS_ENV)
require ENV['RAILS_ROOT'] + '/config/boot'
require ENV['RAILS_ROOT'] + '/config/environment'

class ActiveRecord::Base
  class << self
    alias old_inherited inherited 
  end

  def self.inherited(subclass)
    Log.info("Found active record #{subclass}")
    @@classes << subclass
    old_inherited(subclass)
  end
end

@@classes = []

# Returns an array of class names for all subclasses of ActiveRecord::Base
# found in app/models.
def active_record_classes
  Dir.glob(ENV['RAILS_ROOT'] + "/app/models/**/*.rb").each do |f|
    require f
  end
end

configure do
  Log = Logger.new("sinatra.log") # or log/development.log, whichever you prefer
  Log.level  = Logger::INFO

  Log.info("Connecting to localhost")
  ActiveRecord::Base.establish_connection(
    :adapter  => "mysql",
    :host     => "localhost",
    :username => "root",
    :password => "",
    :database => "riderway_development"
  )

  Log.info("Loading active record classes")
  #active_record_classes()

  class ActiveRecord::Base
    def self.explorer_columns
      @@explorer_columns || ["key_name", "name", "title", "description", "desc"]     

      cols = klass.columns.select do |col|
        if klass.explorer_columns.include?(col.name) && [:text, :string].include?(col.type)
          next col.name
        end
        false
      end

      cols.collect {|col| col.name}
    end

    def explorer_columns
      self.class.explorer_columns
    end
  end

  ["config/explorer.yaml"].each do |path|
    if File.exists?(path)
      Log.info("Loading column info from #{path}")
      yaml = File.open('config/explorer.yaml') { |f| YAML::load(f) }
      yaml.each do |klass, columns|
        klass = eval(klass)
        klass.class_eval do
          @@explorer_columns = columns
        end
      end
    end
  end

  set :app_file, __FILE__
  set :reload, true
end

get '/' do
  haml :index
end

get '/show/:class/:id' do
  klass = eval(params[:class])
  @obj = klass.find(params[:id])
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
