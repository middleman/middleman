##
# This file loads certain extensions required by Padrino from ActiveSupport.
#
require 'active_support/core_ext/kernel'                    # silence_warnings
require 'active_support/core_ext/module/aliasing'           # alias_method_chain
require 'active_support/core_ext/class/attribute_accessors' # cattr_reader
require 'active_support/core_ext/hash/keys'                 # symbolize_keys
require 'active_support/core_ext/hash/reverse_merge'        # reverse_merge
require 'active_support/core_ext/hash/slice'                # slice
require 'active_support/core_ext/object/blank'              # present?
require 'active_support/core_ext/array/extract_options'     # extract_options
require 'active_support/inflector/methods'                  # constantize
require 'active_support/inflector/inflections'              # pluralize
require 'active_support/inflections'                        # load default inflections

##
# This is a small version of active_support/core_ext/string/inflections.rb
# to prevent to load a lot of dependencies including I18n gem
#
# Issue: https://github.com/rails/rails/issues/1526
#
class String
  # Returns the plural form of the word in the string.
  #
  #   "post".pluralize             # => "posts"
  #   "octopus".pluralize          # => "octopi"
  #   "sheep".pluralize            # => "sheep"
  #   "words".pluralize            # => "words"
  #   "the blue mailman".pluralize # => "the blue mailmen"
  #   "CamelOctopus".pluralize     # => "CamelOctopi"
  def pluralize
    ActiveSupport::Inflector.pluralize(self)
  end

  # +constantize+ tries to find a declared constant with the name specified
  # in the string. It raises a NameError when the name is not in CamelCase
  # or is not initialized.
  #
  # Examples
  #   "Module".constantize # => Module
  #   "Class".constantize  # => Class
  def constantize
    ActiveSupport::Inflector.constantize(self)
  end

  # By default, +camelize+ converts strings to UpperCamelCase. If the argument to camelize
  # is set to <tt>:lower</tt> then camelize produces lowerCamelCase.
  #
  # +camelize+ will also convert '/' to '::' which is useful for converting paths to namespaces.
  #
  #   "active_record".camelize                # => "ActiveRecord"
  #   "active_record".camelize(:lower)        # => "activeRecord"
  #   "active_record/errors".camelize         # => "ActiveRecord::Errors"
  #   "active_record/errors".camelize(:lower) # => "activeRecord::Errors"
  def camelize(first_letter = :upper)
    case first_letter
      when :upper then ActiveSupport::Inflector.camelize(self, true)
      when :lower then ActiveSupport::Inflector.camelize(self, false)
    end
  end
  alias_method :camelcase, :camelize

  # The reverse of +camelize+. Makes an underscored, lowercase form from the expression in the string.
  #
  # +underscore+ will also change '::' to '/' to convert namespaces to paths.
  #
  #   "ActiveRecord".underscore         # => "active_record"
  #   "ActiveRecord::Errors".underscore # => active_record/errors
  def underscore
    ActiveSupport::Inflector.underscore(self)
  end

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
  def classify
    ActiveSupport::Inflector.classify(self)
  end
end

module ObjectSpace
  class << self
    # Returns all the classes in the object space.
    def classes
      ObjectSpace.each_object(Module).select do |klass|
        Class.class_eval { klass } rescue false
      end
    end
  end
end

##
# FileSet helper method for iterating and interacting with files inside a directory
#
class FileSet
  # Iterates over every file in the glob pattern and yields to a block
  # Returns the list of files matching the glob pattern
  # FileSet.glob('padrino-core/application/*.rb', __FILE__) { |file| load file }
  def self.glob(glob_pattern, file_path=nil, &block)
    glob_pattern = File.join(File.dirname(file_path), glob_pattern) if file_path
    file_list = Dir.glob(glob_pattern).sort
    file_list.each { |file| block.call(file) }
    file_list
  end

  # Requires each file matched in the glob pattern into the application
  # FileSet.glob_require('padrino-core/application/*.rb', __FILE__)
  def self.glob_require(glob_pattern, file_path=nil)
    self.glob(glob_pattern, file_path) { |f| require f }
  end
end

##
# YAML Engine Parsing Fix
# https://github.com/padrino/padrino-framework/issues/424
#
require 'yaml' unless defined?(YAML)
YAML::ENGINE.yamler = "syck" if defined?(YAML::ENGINE)

##
# Loads our locale configuration files
#
I18n.load_path += Dir["#{File.dirname(__FILE__)}/locale/*.yml"] if defined?(I18n)

##
# Used to know if this file has already been required
#
module SupportLite; end