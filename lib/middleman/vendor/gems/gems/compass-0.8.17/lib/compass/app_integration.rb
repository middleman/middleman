# If we're running inside Rails
require File.join(File.dirname(__FILE__), 'app_integration', 'rails') if defined?(ActionController::Base)

# If we're running inside Merb
require File.join(File.dirname(__FILE__), 'app_integration', 'merb') if defined?(Merb::Plugins)
