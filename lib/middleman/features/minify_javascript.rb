module Middleman::Features::MinifyJavascript
  class << self
    def registered(app)
      # Only do minification on build or prod mode
      return unless [:build, :production].include? app.environment

      require "middleman/features/minify_javascript/rack"
      app.use Middleman::Rack::MinifyJavascript
    end
    alias :included :registered
  end
end