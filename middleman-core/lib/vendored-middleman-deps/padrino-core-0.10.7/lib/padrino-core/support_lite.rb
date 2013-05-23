##
# This file loads certain extensions required by Padrino from ActiveSupport.
#
require 'active_support/core_ext/module/aliasing'           # alias_method_chain
require 'active_support/core_ext/hash/keys'                 # symbolize_keys
require 'active_support/core_ext/hash/reverse_merge'        # reverse_merge
require 'active_support/core_ext/hash/slice'                # slice
require 'active_support/core_ext/object/blank'              # present?
require 'active_support/core_ext/array/extract_options'     # extract_options
require 'active_support/inflector/methods'                  # constantize
require 'active_support/inflector/inflections'              # pluralize
require 'active_support/inflections'                        # load default inflections
require 'yaml' unless defined?(YAML)                        # load yaml for i18n
require 'win32console' if RUBY_PLATFORM =~ /(win|m)32/      # ruby color support for win

##
# This is an adapted version of active_support/core_ext/string/inflections.rb
# to prevent loading several dependencies including I18n gem.
#
# Issue: https://github.com/rails/rails/issues/1526
#
class String
  ##
  # Returns the plural form of the word in the string.
  #
  #   "post".pluralize             # => "posts"
  #   "octopus".pluralize          # => "octopi"
  #   "sheep".pluralize            # => "sheep"
  #   "words".pluralize            # => "words"
  #   "the blue mailman".pluralize # => "the blue mailmen"
  #   "CamelOctopus".pluralize     # => "CamelOctopi"
  #
  def pluralize
    ActiveSupport::Inflector.pluralize(self)
  end

  ##
  # Returns the singular form of the word in the string.
  #
  #   "posts".singularize            # => "post"
  #   "octopi".singularize           # => "octopus"
  #   "sheep".singularize            # => "sheep"
  #   "words".singularize            # => "word"
  #   "the blue mailmen".singularize # => "the blue mailman"
  #   "CamelOctopi".singularize      # => "CamelOctopus"
  #
  def singularize
    ActiveSupport::Inflector.singularize(self)
  end

  ##
  # +constantize+ tries to find a declared constant with the name specified
  # in the string. It raises a NameError when the name is not in CamelCase
  # or is not initialized.
  #
  #   "Module".constantize # => Module
  #   "Class".constantize  # => Class
  #
  def constantize
    ActiveSupport::Inflector.constantize(self)
  end

  ##
  # The reverse of +camelize+. Makes an underscored, lowercase form from the expression in the string.
  #
  # +underscore+ will also change '::' to '/' to convert namespaces to paths.
  #
  #   "ActiveRecord".underscore         # => "active_record"
  #   "ActiveRecord::Errors".underscore # => active_record/errors
  #
  def underscore
    ActiveSupport::Inflector.underscore(self)
  end

  ##
  # By default, +camelize+ converts strings to UpperCamelCase. If the argument to camelize
  # is set to <tt>:lower</tt> then camelize produces lowerCamelCase.
  #
  # +camelize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
  #
  #   "active_record".camelize                # => "ActiveRecord"
  #   "active_record".camelize(:lower)        # => "activeRecord"
  #   "active_record/errors".camelize         # => "ActiveRecord::Errors"
  #   "active_record/errors".camelize(:lower) # => "activeRecord::Errors"
  #
  def camelize(first_letter = :upper)
    case first_letter
      when :upper then ActiveSupport::Inflector.camelize(self, true)
      when :lower then ActiveSupport::Inflector.camelize(self, false)
    end
  end
  alias_method :camelcase, :camelize

  ##
  # Create a class name from a plural table name like Rails does for table names to models.
  # Note that this returns a string and not a class. (To convert to an actual class
  # follow +classify+ with +constantize+.)
  #
  #   "egg_and_hams".classify # => "EggAndHam"
  #   "posts".classify        # => "Post"
  #
  # Singular names are not handled correctly.
  #
  #   "business".classify # => "Busines"
  #
  def classify
    ActiveSupport::Inflector.classify(self)
  end
end

module ObjectSpace
  class << self
    # Returns all the classes in the object space.
    def classes
      ObjectSpace.each_object(Module).select do |klass|
        # Why? Ruby, when you remove a costant dosen't remove it from
        # rb_tables, this mean that here we can find classes that was
        # removed.
        klass.name rescue false
      end
    end
  end
end

##
# FileSet helper method for iterating and interacting with files inside a directory
#
module FileSet
  extend self
  ##
  # Iterates over every file in the glob pattern and yields to a block
  # Returns the list of files matching the glob pattern
  # FileSet.glob('padrino-core/application/*.rb', __FILE__) { |file| load file }
  #
  def glob(glob_pattern, file_path=nil, &block)
    glob_pattern = File.join(File.dirname(file_path), glob_pattern) if file_path
    file_list = Dir.glob(glob_pattern).sort
    file_list.each { |file| block.call(file) }
    file_list
  end

  ##
  # Requires each file matched in the glob pattern into the application
  # FileSet.glob_require('padrino-core/application/*.rb', __FILE__)
  #
  def glob_require(glob_pattern, file_path=nil)
    glob(glob_pattern, file_path) { |f| require f }
  end
end

##
# Removes indentation
# Add colors
#
# @example
#   help <<-EOS.undent
#     Here my help usage
#      sample_code
#
#     Fix
#   EOS
#   puts help.red.bold
#
class String
  def self.colors
    @_colors ||= {
      :clear   => 0,
      :bold    => 1,
      :black   => 30,
      :red     => 31,
      :green   => 32,
      :yellow  => 33,
      :blue    => 34,
      :magenta => 35,
      :cyan    => 36,
      :white   => 37
    }
  end

  colors.each do |color, value|
    define_method(color) do
      ["\e[", value.to_s, "m", self, "\e[", self.class.colors[:clear], "m"] * ''
    end
  end

  def undent
    gsub(/^.{#{slice(/^ +/).size}}/, '')
  end
end

##
# Make sure we can always use the class name
# In reloader for accessing class_name Foo._orig_klass_name
#
class Module
  alias :_orig_klass_name :to_s
end

##
# Loads our locale configuration files
#
I18n.load_path += Dir["#{File.dirname(__FILE__)}/locale/*.yml"] if defined?(I18n)

##
# Used to determine if this file has already been required
#
module SupportLite; end
