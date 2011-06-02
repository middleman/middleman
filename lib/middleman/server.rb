# We're riding on Sinatra, so let's include it.
require "sinatra/base"

# Use the padrino project's helpers
require "padrino-core/application/rendering"
require "padrino-helpers"

module Middleman
  class Server < Sinatra::Base
    # Basic Sinatra config
    set :app_file,    __FILE__
    set :root,        ENV["MM_DIR"] || Dir.pwd
    set :reload,      false
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
    
    set :static, false
    set :views, "source"
    
    # Disable Padrino cache buster until explicitly enabled
    set :asset_stamp, false
    
    # Use Padrino Helpers
    register Padrino::Helpers
    
    # Activate custom features
    register Middleman::Features
    
    # Activate built-in helpers
    register Middleman::Features::DefaultHelpers
    
    # Activate Yaml Data package
    register Middleman::Features::Data
    
    # Activate Webservices Proxy package
    # register Middleman::Features::Proxy
    
    # Activate Lorem helpers
    register Middleman::Features::Lorem
    
    # Tilt-aware renderer
    register Padrino::Rendering
    
    # Override Sinatra's set to accept a block
    def self.set(option, value=self, &block)
      if block_given?
        value = Proc.new { block }
      end
      
      super(option, value, &nil)
    end
    
    # An array of callback procs to run after all features have been setup
    @@run_after_features = []
    
    # Add a block/proc to be run after features have been setup
    def self.after_feature_init(&block)
      @@run_after_features << block
    end
    
    # Activate custom renderers
    register Middleman::Renderers::Slim
    register Middleman::Renderers::Haml
    register Middleman::Renderers::Sass
    
    # Rack helper for adding mime-types during local preview
    def self.mime(ext, type)
      ext = ".#{ext}" unless ext.to_s[0] == ?.
      ::Rack::Mime::MIME_TYPES[ext.to_s] = type
    end
    
    # Default layout name
    layout :layout
    
    def self.current_layout
      @layout
    end
    
    # Takes a block which allows many pages to have the same layout
    # with_layout :admin do
    #   page "/admin/"
    #   page "/admin/login.html"
    # end
    def self.with_layout(layout_name, &block)
      old_layout = current_layout
      
      layout(layout_name)
      class_eval(&block) if block_given?
    ensure
      layout(old_layout)
    end
    
    # The page method allows the layout to be set on a specific path
    # page "/about.html", :layout => false
    # page "/", :layout => :homepage_layout
    def self.page(url, options={}, &block)
      url = url.gsub(%r{#{settings.index_file}$}, "")
      url = url.gsub(%r{(\/)$}, "") if url.length > 1
      
      paths = [url]
      paths << "#{url}/" if url.length > 1 && url.split("/").last.split('.').length <= 1
      paths << "/#{path_to_index(url)}"
  
      options[:layout] = current_layout if options[:layout].nil?

      paths.each do |p|
        get(p) do
          return yield if block_given?
          process_request(options)
        end
      end
    end

    # This will match all requests not overridden in the project's config.rb
    not_found do
      process_request
    end
    
  private
    def self.path_to_index(path)
      parts = path ? path.split('/') : []
      if parts.last.nil? || parts.last.split('.').length == 1
        path = File.join(path, settings.index_file) 
      end
      path.gsub(%r{^/}, '')
    end
  
    # Internal method to look for templates and evaluate them if found
    def process_request(options={})
      # Normalize the path and add index if we're looking at a directory
      path = self.class.path_to_index(request.path)
      
      extensionless_path, template_engine = resolve_template(path)
      
      if !::Tilt.mappings.has_key?(template_engine.to_s)
        send_file File.join(Middleman::Server.views, path)
        return
      end
      
      old_layout = settings.current_layout
      settings.layout(options[:layout]) if !options[:layout].nil?
      layout = settings.fetch_layout_path.to_sym
      layout = false if options[:layout] == false or path =~ /\.(css|js)$/
      
      render_options = { :layout => layout }
      render_options[:layout_engine] = options[:layout_engine] if options.has_key? :layout_engine
      result = render(path, render_options)
      settings.layout(old_layout)
      
      if result
        content_type mime_type(File.extname(path)), :charset => 'utf-8'
        status 200
        return result
      end
      
      status 404
    rescue Padrino::Rendering::TemplateNotFound
      $stderr.puts "File not found: #{request.path}"
      status 404
    end
  end
end

require "middleman/assets"

# The Rack App
class Middleman::Server
  def self.new(*args, &block)  
    # Check for and evaluate local configuration
    local_config = File.join(self.root, "config.rb")
    if File.exists? local_config
      $stderr.puts "== Reading:  Local config" if logging?
      Middleman::Server.class_eval File.read(local_config)
      set :app_file, File.expand_path(local_config)
    end
    
    @@run_after_features.each { |block| class_eval(&block) }
    
    super
  end
end
