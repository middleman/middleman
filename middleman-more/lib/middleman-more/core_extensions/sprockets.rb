# Require gem
require "sprockets"

# Sprockets extension
module Middleman::CoreExtensions::Sprockets

  # Setup extension
  class << self

    # Once registered
    def registered(app)
      # Default compression to off
      app.set :js_compressor, false
      app.set :css_compressor, false

      # Once Middleman is setup
      app.ready do
        # Create sprockets env for JS and CSS
        js_env = Middleman::CoreExtensions::Sprockets::JavascriptEnvironment.new(self)
        css_env = Middleman::CoreExtensions::Sprockets::StylesheetEnvironment.new(self)

        # Add any gems with (vendor|app|.)/assets/javascripts to paths
        # also add similar directories from project root (like in rails)
        root_paths = [%w{ app }, %w{ assets }, %w{ vendor }, %w{ app assets }, %w{ vendor assets }]
        try_js_paths  = root_paths.map{|rp| File.join(rp, 'javascripts')}
        try_css_paths = root_paths.map{|rp| File.join(rp, 'stylesheets')}

        { try_js_paths => js_env, try_css_paths => css_env }.each do |paths, env|
          ([root] + ::Middleman.rubygems_latest_specs.map(&:full_gem_path)).each do |root_path|
            paths.map{|p| File.join(root_path, p)}.
              select{|p| File.directory?(p)}.
              each{|path| env.append_path(path)}
          end
        end

        # Setup Sprockets Sass options
        sass.each { |k, v| ::Sprockets::Sass.options[k] = v }

        # Intercept requests to /javascripts and /stylesheets and pass to sprockets
        map("/#{js_dir}") { run js_env }
        map("/#{css_dir}"){ run css_env }
      end
    end
    alias :included :registered
  end

  # Generic Middleman Sprockets env
  class MiddlemanEnvironment < ::Sprockets::Environment
    # Setup
    def initialize(app)
      @app = app
      super app.source_dir

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
    end

    # During development, don't use the asset cache
    def find_asset(path, options = {})
      expire_index! if @app.development?
      super
    end
  end

  # Javascript specific environment
  class JavascriptEnvironment < MiddlemanEnvironment

    # Init
    def initialize(app)
      super

      expire_index!

      # Remove old compressor
      unregister_bundle_processor 'application/javascript', :js_compressor

      # Register compressor from config
      register_bundle_processor 'application/javascript', :js_compressor do |context, data|
        if context.pathname.to_s =~ /\.min\./
          data
        else
          app.js_compressor.compress(data)
        end
      end if app.js_compressor

      # configure search paths
      append_path app.js_dir
    end

    # Clear cache on error
    def javascript_exception_response(exception)
      expire_index!
      super(exception)
    end
  end

  # CSS specific environment
  class StylesheetEnvironment < MiddlemanEnvironment

    # Init
    def initialize(app)
      super

      expire_index!

      # Remove old compressor
      unregister_bundle_processor 'text/css', :css_compressor

      # Register compressor from config
      register_bundle_processor 'text/css', :css_compressor do |context, data|
        if context.pathname.to_s =~ /\.min\./
          data
        else
          app.css_compressor.compress(data)
        end
      end if app.css_compressor

      # configure search paths
      append_path app.css_dir
    end

    # Clear cache on error
    def css_exception_response(exception)
      expire_index!
      super(exception)
    end
  end
end
