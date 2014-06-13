# Support rack/showexceptions during development
module Middleman::CoreExtensions
  class ShowExceptions < ::Middleman::Extension
    def initialize(app, options_hash={}, &block)
      super

      require 'rack/showexceptions'
    end

    def after_configuration
      app.use ::Rack::ShowExceptions
    end
  end
end
