# Support rack/showexceptions during development
module Middleman::CoreExtensions::ShowExceptions
  
  # Setup extension
  class << self
    
    # Once registered
    def registered(app)
      # Require lib
      require 'rack/showexceptions'
      
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