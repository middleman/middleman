%w(configuration_defaults installer).each do |lib|
  require "compass/app_integration/rails/#{lib}"
end

require 'compass/app_integration/rails/runtime' if defined?(ActionController::Base)


module Compass
  module AppIntegration
    module Rails

      extend self

      def installer(*args)
        Installer.new(*args)
      end

      def configuration
        Compass::Configuration::Data.new('rails').
          extend(ConfigurationDefaults)
      end

    end
  end
end

