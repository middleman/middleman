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
      
      # Cut off every extension after .js (which sprockets eats up)
      app.build_reroute do |destination, request_path|
        if !request_path.match(/\.js\./i)
          false
        else
          [
            destination.gsub(/\.js(\..*)$/, ".js"),
            request_path.gsub(/\.js(\..*)$/, ".js")
          ]
        end
      end
      
      # Once Middleman is setup
      app.ready do
        # Create sprockets env for JS
        js_env = Middleman::CoreExtensions::Sprockets::JavascriptEnvironment.new(self)

        # Add any gems with vendor/assets/javascripts to paths
        vendor_dir = File.join("vendor", "assets", "javascripts")
        gems_with_js = ::Middleman.rubygems_latest_specs.select do |spec|
          ::Middleman.spec_has_file?(spec, vendor_dir)
        end.each do |spec|
          js_env.append_path File.join(spec.full_gem_path, vendor_dir)
        end

        # Add any gems with app/assets/javascripts to paths
        app_dir = File.join("app", "assets", "javascripts")
        gems_with_js = ::Middleman.rubygems_latest_specs.select do |spec|
          ::Middleman.spec_has_file?(spec, app_dir)
        end.each do |spec|
          js_env.append_path File.join(spec.full_gem_path, app_dir)
        end

        # Intercept requests to /javascripts and pass to sprockets
        map "/#{js_dir}" do
          run js_env
        end

        # Setup Sprockets Sass options
        sass.each { |k, v| ::Sprockets::Sass.options[k] = v }
        
        # Create sprockets env for CSS
        css_env = Middleman::CoreExtensions::Sprockets::StylesheetEnvironment.new(self)
         
        # Add any gems with vendor/assets/stylesheets to paths
        vendor_dir = File.join("vendor", "assets", "stylesheets")
        gems_with_css = ::Middleman.rubygems_latest_specs.select do |spec|
          ::Middleman.spec_has_file?(spec, vendor_dir)
        end.each do |spec|
          css_env.append_path File.join(spec.full_gem_path, vendor_dir)
        end
        
        # Add any gems with app/assets/stylesheets to paths
        app_dir = File.join("app", "assets", "stylesheets")
        gems_with_css = ::Middleman.rubygems_latest_specs.select do |spec|
          ::Middleman.spec_has_file?(spec, app_dir)
        end.each do |spec|
          css_env.append_path File.join(spec.full_gem_path, app_dir)
        end
        
        # Intercept requests to /stylesheets and pass to sprockets
        map("/#{css_dir}") do
          run css_env
        end
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