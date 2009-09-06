require 'rubygems'
require 'activerecord'

class Class
  attr_accessor :display_atts
end

module Ari

  # :stopdoc:
  VERSION = '1.0.0'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
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
  def get_class(name)
    begin
      return eval(name)
    rescue NameError;
    end
    nil
  end

  # Loads class attribute names from +path+ or
  # ENV["RAILS_ROOT"]/config/ari.yaml if it exists.
  def load_display_atts(path = nil)
    ActiveRecord::Base.display_atts = ["name", "description"]

    path = File.join(ENV["RAILS_ROOT"], "config", "explorer.yaml") unless path

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
