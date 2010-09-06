# We're riding on Sinatra, so let's include it.
require "sinatra/base"

# The content_for plugin allows Sinatra to use the throw/yield block
# system similar to Rails views.
require "sinatra/content_for"

# Monkey-patch Sinatra to expose the layout parameter
class Sinatra::Request
  attr_accessor :layout
end

module Middleman
  class Server < Sinatra::Base
    # Basic Sinatra config
    set :app_file,    __FILE__
    set :root,        ENV["MM_DIR"] || Dir.pwd
    set :reload,      false
    set :sessions,    false
    set :logging,     false
    set :environment, (ENV['MM_ENV'] && ENV['MM_ENV'].to_sym) || :development
    
    # Import content_for methods
    helpers Sinatra::ContentFor
    
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
    
    # A hash of enabled features
    @@enabled_features = {}
    
    # Override Sinatra's enable to keep track of enabled features
    def self.enable(feature_name, config={})
      @@enabled_features[feature_name] = config
      super(feature_name)
    end
    
    # Disable a feature, then pass to Sinatra's method
    def self.disable(feature_name)
      @@enabled_features.delete(feature_name)
      super(feature_name)
    end
    
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
    
    # Rack helper for adding mime-types during local preview
    def self.mime(ext, type)
      ext = ".#{ext}" unless ext.to_s[0] == ?.
      ::Rack::Mime::MIME_TYPES[ext.to_s] = type
    end
    
    # Keep track of a block-specific layout
    @@layout = nil
    
    # Takes a block which allows many pages to have the same layout
    # with_layout :admin do
    #   page "/admin/"
    #   page "/admin/login.html"
    # end
    def self.with_layout(layout, &block)
      @@layout = layout
      class_eval(&block) if block_given?
    ensure
      @@layout = nil
    end
    
    # The page method allows the layout to be set on a specific path
    # page "/about.html", :layout => false
    # page "/", :layout => :homepage_layout
    def self.page(url, options={}, &block)
      layout = @@layout
      layout = options[:layout] if !options[:layout].nil?
      
      get(url) do
        return yield if block_given?
        process_request(layout)
      end
    end

    # This will match all requests not overridden in the project's config.rb
    not_found do
      process_request
    end
    
  private
    # Internal method to look for templates and evaluate them if found
    def process_request(layout = :layout)
      # Normalize the path and add index if we're looking at a directory
      path = request.path
      path << settings.index_file if path.match(%r{/$})
      path.gsub!(%r{^/}, '')

      if template_path = Dir.glob(File.join(settings.views, "#{path}.*")).first
        content_type mime_type(File.extname(path)), :charset => 'utf-8'
        
        renderer = Middleman::Renderers.get_method(template_path)
        if respond_to? renderer
          status 200
          return send(renderer, path.to_sym, { :layout => layout })
        end
      end
      
      status 404
    end
  end
end

require "middleman/assets"
require "middleman/renderers"
require "middleman/features"

# The Rack App
class Middleman::Server
  def self.new(*args, &block)
    # If the old init.rb exists, use it, but issue warning
    old_config = File.join(self.root, "init.rb")
    if File.exists? old_config
      $stderr.puts "== Warning: The init.rb file has been renamed to config.rb"
      local_config = old_config
    end
    
    # Check for and evaluate local configuration
    local_config ||= File.join(self.root, "config.rb")
    if File.exists? local_config
      $stderr.puts "== Reading:  Local config" if logging?
      Middleman::Server.class_eval File.read(local_config)
      set :app_file, File.expand_path(local_config)
    end
    
    # loop over enabled feature
    @@enabled_features.each do |feature_name, feature_config|
      next unless send(:"#{feature_name}?")
      $stderr.puts "== Enabling: #{feature_name.to_s.capitalize}" if logging?
      Middleman::Features.run(feature_name, feature_config, self)
    end
    
    use ::Rack::ConditionalGet if environment == :development
    
    @@run_after_features.each { |block| class_eval(&block) }
    
    super
  end
end
