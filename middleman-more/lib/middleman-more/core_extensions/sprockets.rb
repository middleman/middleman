# Require gem
require "sprockets"

# Sprockets extension
module Middleman::CoreExtensions::Sprockets

  # Setup extension
  class << self

    # Once registered
    def registered(app)
      # Add class methods to context
      app.send :include, InstanceMethods

      # Once Middleman is setup
      app.ready do
        # Add any gems with (vendor|app|.)/assets/javascripts to paths
        # also add similar directories from project root (like in rails)
        root_paths = [%w{ app }, %w{ assets }, %w{ vendor }, %w{ app assets }, %w{ vendor assets }]
        try_paths  = root_paths.map {|rp| File.join(rp, 'javascripts') } +
                     root_paths.map {|rp| File.join(rp, 'stylesheets') }

        ([root] + ::Middleman.rubygems_latest_specs.map(&:full_gem_path)).each do |root_path|
          try_paths.map {|p| File.join(root_path, p) }.
            select {|p| File.directory?(p) }.
            each {|path| sprockets.append_path(path) }
        end

        # Setup Sprockets Sass options
        sass.each { |k, v| ::Sprockets::Sass.options[k] = v }

        # Intercept requests to /javascripts and /stylesheets and pass to sprockets
        our_sprockets = sprockets
        map("/#{js_dir}")  { run our_sprockets }
        map("/#{css_dir}") { run our_sprockets }
      end
    end
    alias :included :registered
  end

  module InstanceMethods
    # @return [Middleman::CoreExtensions::Sprockets::MiddlemanSprocketsEnvironment]
    def sprockets
      @sprockets ||= MiddlemanSprocketsEnvironment.new(self)
    end
  end

  # Generic Middleman Sprockets env
  class MiddlemanSprocketsEnvironment < ::Sprockets::Environment
    # Setup
    def initialize(app)
      @app = app
      super app.source_dir

      digest = Digest::SHA1

      # Make the app context available to Sprockets
      context_class.send(:define_method, :app) { app }
      context_class.class_eval do
        def method_missing(name)
          if app.respond_to?(name)
            app.send(name)
          else
            super
          end
        end
      end

      # Remove compressors, we handle these with middleware
      unregister_bundle_processor 'application/javascript', :js_compressor
      unregister_bundle_processor 'text/css', :css_compressor

      # configure search paths
      append_path app.js_dir
      append_path app.css_dir
    end

    # During development, don't use the asset cache
    def find_asset(path, options = {})
      expire_index! if @app.development?
      super
    end

    # Clear cache on error
    def javascript_exception_response(exception)
      expire_index!
      super(exception)
    end

    # Clear cache on error
    alias :css_exception_response :javascript_exception_response
  end
end
