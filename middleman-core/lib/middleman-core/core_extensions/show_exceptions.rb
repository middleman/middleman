# Support rack/showexceptions during development
module Middleman
  module CoreExtensions
    module ShowExceptions
      def self.included(app)
        # Require lib
        require 'rack/showexceptions'

        # Whether to catch and display exceptions
        # @return [Boolean]
        app.config.define_setting :show_exceptions, true, 'Whether to catch and display exceptions'

        # When in dev
        app.configure :development do
          # Include middlemare
          if config[:show_exceptions]
            use ::Rack::ShowExceptions
          end
        end
      end
    end
  end
end
