require 'rack/show_exceptions'

# Support rack/showexceptions during development
module Middleman::CoreExtensions
  class ShowExceptions < ::Middleman::Extension
    define_setting :show_exceptions, ENV['TEST'] ? false : true, 'Whether to catch and display exceptions'

    def ready
      app.use ::Rack::ShowExceptions if !app.build? && app.config[:show_exceptions]
    end
  end
end
