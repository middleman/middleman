# We're riding on Sinatra, so let's include it.
require "sinatra/base"

module Middleman
  class Server < Sinatra::Base
    # Basic Sinatra config
    set :app_file,    __FILE__
    set :root,        ENV["MM_DIR"] || Dir.pwd
    set :sessions,    false
    set :logging,     false
    set :environment, (ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :development
    
    # Middleman-specific options
    set :index_file,  "index.html"  # What file responds to folder requests
                                    # Such as the homepage (/) or subfolders (/about/)
    
    # These directories are passed directly to Compass
    set :js_dir,      "javascripts" # Where to look for javascript files
    set :css_dir,     "stylesheets" # Where to look for CSS files
    set :images_dir,  "images"      # Where to look for images
    set :fonts_dir,   "fonts"       # Where to look for fonts
    
    set :build_dir,   "build"       # Which folder are builds output to
    set :http_prefix, nil           # During build, add a prefix for absolute paths
    
    # Pass all request to Middleman, even "static" files
    set :static, false
    
    set :views, "source"
    
    # Activate custom features
    register Middleman::CoreExtensions::Features
    
    # Setup custom rendering
    register Middleman::CoreExtensions::Rendering
    
    # Setup asset path pipeline
    register Middleman::CoreExtensions::Assets
    
    # Activate built-in helpers
    register Middleman::CoreExtensions::DefaultHelpers
    
    # Activate Yaml Data package
    register Middleman::CoreExtensions::Data
    
    # with_layout and page routing
    register Middleman::CoreExtensions::Routing
    
    # Parse YAML from templates
    register Middleman::CoreExtensions::FrontMatter
    
    set :default_features, [
      :lorem
    ]
    
    # Override Sinatra's set to accept a block
    # Specifically for the asset_host feature
    def self.set(option, value=self, &block)
      if block_given?
        value = Proc.new { block }
      end
      
      super(option, value, &nil)
    end
    
    # Default layout name
    set :layout, :layout

    # This will match all requests not overridden in the project's config.rb
    not_found do
      process_request
    end
    
    # See if Tilt cannot handle this file
    before do
      result = resolve_template(request.path_info, :raise_exceptions => false)
      if result
        extensionless_path, template_engine = result
      
        # Return static files
        if !::Tilt.mappings.has_key?(template_engine.to_s)
          content_type mime_type(File.extname(request.path_info)), :charset => 'utf-8'
          status 200
          send_file File.join(Middleman::Server.views, request.path_info)
          request["already_sent"] = true
        end
      else
        $stderr.puts "File not found: #{request.path_info}"
        status 404
        request["already_sent"] = true
      end
    end
    
  private
    # Internal method to look for templates and evaluate them if found
    def process_request(options={})
      return if request["already_sent"]
      
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
      result = render(request.path_info, render_options)
      settings.set :layout, old_layout
      
      if result
        content_type mime_type(File.extname(request.path_info)), :charset => 'utf-8'
        status 200
        body result
      else
        status 404
      end
    end
  end
end