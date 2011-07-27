module Middleman::Base
  class << self
    def registered(app)
      app.extend ClassMethods
      app.send :include, InstanceMethods
      
      # Basic Sinatra config
      app.set :app_file,    __FILE__
      app.set :root,        Dir.pwd
      app.set :sessions,    false
      app.set :logging,     false
      app.set :environment, (ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :development

      # Middleman-specific options
      app.set :index_file,  "index.html"  # What file responds to folder requests
                                      # Such as the homepage (/) or subfolders (/about/)

      # These directories are passed directly to Compass
      app.set :js_dir,      "javascripts" # Where to look for javascript files
      app.set :css_dir,     "stylesheets" # Where to look for CSS files
      app.set :images_dir,  "images"      # Where to look for images
      app.set :fonts_dir,   "fonts"       # Where to look for fonts

      app.set :build_dir,   "build"       # Which folder are builds output to
      app.set :http_prefix, nil           # During build, add a prefix for absolute paths

      # Pass all request to Middleman, even "static" files
      app.set :static, false

      app.set :views, "source"

      # Add Rack::Builder.map to Sinatra
      app.register Middleman::CoreExtensions::RackMap

      # Activate custom features
      app.register Middleman::CoreExtensions::Features

      # Setup custom rendering
      app.register Middleman::CoreExtensions::Rendering

      # Compass framework
      app.register Middleman::CoreExtensions::Compass

      # Sprockets asset handling
      app.register Middleman::CoreExtensions::Sprockets

      # Setup asset path pipeline
      app.register Middleman::CoreExtensions::Assets

      # Activate built-in helpers
      app.register Middleman::CoreExtensions::DefaultHelpers

      # Activate Yaml Data package
      app.register Middleman::CoreExtensions::Data

      # with_layout and page routing
      app.register Middleman::CoreExtensions::Routing

      # Parse YAML from templates
      app.register Middleman::CoreExtensions::FrontMatter

      app.set :default_features, [
        :lorem
      ]

      # Default layout name
      app.set :layout, :layout

      # This will match all requests not overridden in the project's config.rb
      app.not_found do
        process_request
      end

      # Custom 404 handler (to be styled)
      app.error Sinatra::NotFound do
        content_type 'text/html'
        "<html><body><h1>File Not Found</h1><p>#{request.path_info}</p></body>"
      end

      # See if Tilt cannot handle this file
      app.before_processing do
        if !settings.views.include?(settings.root)
          settings.set :views, File.join(settings.root, settings.views)
        end

        request_path = request.path_info.gsub("%20", " ")
        result = resolve_template(request_path, :raise_exceptions => false)
        
        if result
          extensionless_path, template_engine = result

          # Return static files
          if !::Tilt.mappings.has_key?(template_engine.to_s)
            content_type mime_type(File.extname(request_path)), :charset => 'utf-8'
            status 200
            send_file File.join(settings.views, request_path)
            false
          else
            true
          end
        else
          $stderr.puts "File not found: #{request_path}"
          status 404
          false
        end
      end
    end
    alias :included :registered
  end
  
  module ClassMethods
    # Override Sinatra's set to accept a block
    # Specifically for the asset_host feature
    def set(option, value=self, &block)
      if block_given?
        value = Proc.new { block }
      end
    
      super(option, value, &nil)
    end
    
    def before_processing(&block)
      @before_processes ||= []
      @before_processes << block
    end
    
    def execute_before_processing!(inst)
      @before_processes ||= []
      
      @before_processes.all? do |block|
        inst.instance_eval(&block)
      end
    end
    
    # Convenience method to check if we're in build mode
    def build?; environment == :build; end
  end
  
  module InstanceMethods
    # Internal method to look for templates and evaluate them if found
    def process_request(options={})
      return unless settings.execute_before_processing!(self)

      options.merge!(request['custom_options'] || {})

      old_layout = settings.layout
      settings.set :layout, options[:layout] if !options[:layout].nil?

      layout = if settings.layout
        if options[:layout] == false || request.path_info =~ /\.(css|js)$/
          false
        else
          settings.fetch_layout_path(settings.layout).to_sym
        end
      else
        false
      end

      render_options = { :layout => layout }
      render_options[:layout_engine] = options[:layout_engine] if options.has_key? :layout_engine
      request_path = request.path_info.gsub("%20", " ")
      result = render(request_path, render_options)
      settings.set :layout, old_layout

      if result
        content_type mime_type(File.extname(request_path)), :charset => 'utf-8'
        status 200
        body result
      else
        status 404
      end
    end
  end
end