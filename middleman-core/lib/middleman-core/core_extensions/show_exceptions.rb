# Require lib
require 'rack/showexceptions'

# Support rack/showexceptions during development
module Middleman
  module CoreExtensions
    module ShowExceptions

      # Setup extension
      class << self

        # Once registered
        def registered(app)
          # When in dev
          app.configure :development do
            # Include middlemare
            if show_exceptions
              use ::Middleman::CoreExtensions::ShowExceptions::Middleware
            end
          end
        end
      end

      # Custom exception class
      # TODO: Style this ourselves
      class Middleware < ::Rack::ShowExceptions
      end

    end
  end
end
