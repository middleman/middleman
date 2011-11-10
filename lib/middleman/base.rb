require "i18n"
require "hooks"

require "active_support"
require "active_support/json"
require "active_support/core_ext/class/attribute_accessors"

module Middleman::Base
  class << self
    def registered(app)
      app.send :include, ::Hooks
      app.define_hook :initialized
      
      app.extend ClassMethods
      app.send :include, InstanceMethods
      
      # Basic Sinatra config
      app.set :app_file,    __FILE__
      app.set :root,        Dir.pwd
      app.set :sessions,    false
      app.set :logging,     false
      app.set :protection,  false
      app.set :environment, (ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :development

      # Middleman-specific options
      app.set :index_file,  "index.html"  # What file responds to folder requests
                                      # Such as the homepage (/) or subfolders (/about/)

      # These directories are passed directly to Compass
      app.set :js_dir,      "javascripts" # Where to look for javascript files
      app.set :css_dir,     "stylesheets" # Where to look for CSS files
      app.set :images_dir,  "images"      # Where to look for images

      app.set :build_dir,   "build"       # Which folder are builds output to
      app.set :http_prefix, nil           # During build, add a prefix for absolute paths

      # Pass all request to Middleman, even "static" files
      app.set :static, false

      app.set :views, "source"
      
      # Add Builder Callbacks
      app.register Middleman::CoreExtensions::Builder
      
      # Add Rack::Builder.map to Sinatra
      app.register Middleman::CoreExtensions::RackMap
      
      # Activate custom features
      app.register Middleman::CoreExtensions::Features
      
      # Add Builder Callbacks
      app.register Middleman::CoreExtensions::FileWatcher
      
      # Sitemap
      app.register Middleman::CoreExtensions::Sitemap
      
      # Activate Yaml Data package
      app.register Middleman::CoreExtensions::Data
      
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
      
      # with_layout and page routing
      app.register Middleman::CoreExtensions::Routing
      
      # Parse YAML from templates
      app.register Middleman::CoreExtensions::FrontMatter

      app.set :default_features, [
        :lorem,
        :sitemap_tree
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
      app.before_processing(:base) do |result|
        request_path = request.path_info.gsub("%20", " ")

        should_be_ignored = !(request["is_proxy"]) && settings.sitemap.ignored_path?("/#{request_path}")
        
        if result && !should_be_ignored
          extensionless_path, template_engine = result

          # Return static files
          if !::Tilt.mappings.has_key?(template_engine.to_s)
            matched_mime = mime_type(File.extname(request_path))
            matched_mime = "application/octet-stream" if matched_mime.nil?
            content_type matched_mime, :charset => 'utf-8'
            status 200
            send_file File.join(settings.views, request_path)
            false
          else
            true
          end
        else
          if !%w(favicon.ico).include?(request_path)
            $stderr.puts "File not found: #{request_path}"
          end
          
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
    def set(option, value = (not_set = true), ignore_setter = false, &block)
      if block_given?
        value = Proc.new { block }
      end
    
      super(option, value, ignore_setter, &nil)
    end
    
    def before_processing(name=:unnamed, idx=-1, &block)
      @before_processes ||= []
      @before_processes.insert(idx, [name, block])
    end
    
    def execute_before_processing!(inst, resolved_template)
      @before_processes ||= []
      
      @before_processes.all? do |name, block|
        inst.instance_exec(resolved_template, &block)
      end
    end
    
    # Convenience method to check if we're in build mode
    def build?; environment == :build; end
    
    # Creates a Rack::Builder instance with all the middleware set up and
    # an instance of this class as end point.
    def build_new(inst=false)
      builder = Rack::Builder.new
      setup_default_middleware builder
      setup_middleware builder
      builder.run inst || new!
      builder.to_app
    end
  end
  
  module InstanceMethods
    def initialize(*args)
      super
      run_hook :initialized, settings
    end
    
    def forward
      raise ::Sinatra::NotFound
    end
  
    # Internal method to look for templates and evaluate them if found
    def process_request(options={})
      if !settings.views.include?(settings.root)
        settings.set :views, File.join(settings.root, settings.views)
      end  
      
      # Normalize the path and add index if we're looking at a directory
      request.path_info = self.class.path_to_index(request.path)
      request_path = request.path_info.gsub("%20", " ")
      found_template = resolve_template(request_path, :raise_exceptions => false)
      return status(404) unless found_template
      return unless settings.execute_before_processing!(self, found_template)
      
      options.merge!(request['custom_options'] || {})

      old_layout = settings.layout
      settings.set :layout, options[:layout] if !options[:layout].nil?

      local_layout = if settings.layout
        if options[:layout] == false || request.path_info =~ /\.(css|js)$/
          false
        else
          settings.fetch_layout_path(settings.layout).to_sym
        end
      else
        false
      end
      
      render_options = { :layout => local_layout }
      render_options[:layout_engine] = options[:layout_engine] if options.has_key? :layout_engine
      
      path, engine = found_template
      locals = request['custom_locals'] || {}
      
      begin
        result = render(engine, path, render_options, locals)
      
        if result
          content_type mime_type(File.extname(request_path)), :charset => 'utf-8'
          status 200
          body result
        end
      # rescue
      #   status(404)
      ensure
        settings.set :layout, old_layout
      end
    end
  end
end