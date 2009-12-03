module Compass
end

%w(dependencies sass_extensions core_ext version errors).each do |lib|
  require "compass/#{lib}"
end

module Compass
  extend Compass::Version
  VERSION = "#{version[:major]}.#{version[:minor]}.#{version[:patch]}"
  def base_directory
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end
  def lib_directory
    File.expand_path(File.join(File.dirname(__FILE__)))
  end
  module_function :base_directory, :lib_directory
end

%w(configuration frameworks app_integration).each do |lib|
  require "compass/#{lib}"
end
