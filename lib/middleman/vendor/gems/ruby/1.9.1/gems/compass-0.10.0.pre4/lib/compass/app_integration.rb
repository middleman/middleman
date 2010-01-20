%w(stand_alone rails merb).each do |lib|
  require "compass/app_integration/#{lib}"
end

module Compass
  module AppIntegration
    module Helpers
      def lookup(project_type)
        eval "Compass::AppIntegration::#{camelize(project_type)}"
      rescue NameError
        raise Compass::Error, "No application integration exists for #{project_type}"
      end

      protected

      # Stolen from ActiveSupport
      def camelize(s)
        s.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      end

    end
    extend Helpers
  end
end
