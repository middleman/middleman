module Compass
end

['dependencies', 'sass_extensions', 'core_ext', 'version', 'errors'].each do |file|
  require File.join(File.dirname(__FILE__), 'compass', file)
end

module Compass
  extend Compass::Version
  def base_directory
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end
  def lib_directory
    File.expand_path(File.join(File.dirname(__FILE__)))
  end
  module_function :base_directory, :lib_directory
end

require File.join(File.dirname(__FILE__), 'compass', 'configuration')
require File.join(File.dirname(__FILE__), 'compass', 'frameworks')
require File.join(File.dirname(__FILE__), 'compass', 'app_integration')


