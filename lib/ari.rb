require 'rubygems'
require 'active_record'

class Class
  attr_accessor :display_atts, :available_classes
end

class ActiveRecord::ConnectionAdapters::AbstractAdapter
  attr_accessor :config
end

class ActiveRecord::Base
  self.available_classes = []

  class << self
    alias old_inherited inherited 
  end

  def self.inherited(subclass)
    ActiveRecord::Base.available_classes << subclass
    old_inherited(subclass)
  end

  self.display_atts = ["name"]

  def self.search_columns
    cols = []

    klass = self
    while klass
      cols << klass.display_atts
      klass = klass.superclass
    end

    cols.flatten.uniq & self.column_names
  end

  def self.find_all_for_ari(q)
    cols = search_columns

    clause = ""
    cols.each_with_index do |col, i|
      clause << " OR " unless i == 0
      clause << "#{col} LIKE ?"
    end
    clause

    self.all(:conditions => [clause] + cols.collect {"%#{q}%"}, :order => cols.first)
  end

  Member = Struct.new(:name, :type, :value)

  def members
    members = []

    attributes.each do |name, value|
      members << Member.new(name, :attr, value)
    end

    self.class.reflections.each do |name, reflection|
      case reflection.macro
        when :has_many
          members << Member.new(name, reflection.macro, self.send(name).send(:count))
        else
          members << Member.new(name, reflection.name, "foo")
      end
    end

    members
  end
end

module Ari
  # :stopdoc:
  VERSION = '1.0.0'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  RAILS_ROOT = File.expand_path(ENV["RAILS_ROOT"] || Dir.pwd)
  RAILS_ENV = ENV["RAILS_ENV"] || "development"
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end

  # Utility method used to require all files ending in .rb that lie in the
  # directory below this file that has the same name as the filename passed
  # in. Optionally, a specific _directory_ name can be passed in such that
  # the _filename_ does not have to be equivalent to the directory.
  #
  def self.require_all_libs_relative_to( fname, dir = nil )
    dir ||= ::File.basename(fname, '.*')
    search_me = ::File.expand_path(
        ::File.join(::File.dirname(fname), dir, '**', '*.rb'))

    Dir.glob(search_me).sort.each {|rb| require rb}
  end

  # Returns the class for +name+ or nil.
  def self.get_class(name)
    begin
      return eval(name)
    rescue NameError;
    end
    nil
  end

  # Finds and load database.yml and establishes the ActiveRecord connection.
  def self.boot_active_record
    database_yaml_path = File.join(RAILS_ROOT, "config", "database.yml")
    raise "Couldn't find database.yml" unless File.exists?(database_yaml_path)

    config = YAML.load(ERB.new(File.read(database_yaml_path)).result(binding))

    ActiveRecord::Base.establish_connection(config[RAILS_ENV])
    Dir.glob(ENV['RAILS_ROOT'] + "/app/models/**/*.rb").each {|f| require f}
  end

  # Loads display attributes from +path+ or
  # ENV["RAILS_ROOT"]/config/ari.yaml if it exists.
  def self.load_display_atts(path = nil)
    ActiveRecord::Base.display_atts = ["name", "description"]

    path = File.join(ENV["RAILS_ROOT"], "config", "ari.yaml") unless path

    return unless File.exists?(path)

    yaml = File.open(path) { |f| YAML::load(f) }
    yaml.each do |klass, atts|
      next unless klass = get_class(klass)
      klass.display_atts = atts
    end
  end

end  # module Ari

Ari.require_all_libs_relative_to(__FILE__)



# EOF
