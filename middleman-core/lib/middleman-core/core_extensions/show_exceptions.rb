require 'rack/showexceptions'

module Middleman::CoreExtensions::ShowExceptions
  class << self
    def registered(app)
      app.configure :development do
        if show_exceptions
          use ::Middleman::CoreExtensions::ShowExceptions::Middleware
        end
      end
    end
  end
  
  class Middleware < ::Rack::ShowExceptions
  end
end
