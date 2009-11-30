%w(configuration_defaults installer).each do |lib|
  require "compass/app_integration/stand_alone/#{lib}"
end

module Compass
  module AppIntegration
    module StandAlone

      extend self

      def installer(*args)
        Installer.new(*args)
      end

      def configuration
        Compass::Configuration::Data.new('stand_alone').
          extend(ConfigurationDefaults)
      end

    end
  end
end
