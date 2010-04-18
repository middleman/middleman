# We're riding on Sinatra, so let's include it
require "sinatra/base"
require "sinatra/content_for"

class Sinatra::Request
  attr_accessor :layout
end

module Middleman
  module Rack; end
  class Base < Sinatra::Base
    set :app_file, __FILE__
    set :root, ENV["MM_DIR"] || Dir.pwd
    set :reload, false
    set :logging, false
    set :environment, ENV['MM_ENV'] || :development
    set :supported_formats, %w(erb)
    set :index_file, "index.html"
    set :js_dir, "javascripts"
    set :css_dir, "stylesheets"
    set :images_dir, "images"
    set :fonts_dir, "fonts"
    set :build_dir, "build"
    set :http_prefix, nil
    
    use ::Rack::ConditionalGet if environment == :development
    helpers Sinatra::ContentFor
    
    set :features, []
    def self.enable(*opts)
      set :features, (self.features << opts).flatten
      super
    end
    
    def self.disable(*opts)
      current = self.features
      current -= opts.flatten
      set :features, current
      super
    end
    
    def self.set(option, value=self, &block)
      if block_given?
        value = Proc.new { block }
        super(option, value, &nil)
      else
        super
      end
    end
    
    @@afters = []
    def self.after_feature_init(&block)
      @@afters << block
    end
    
    # Rack helper for adding mime-types during local preview
    def self.mime(ext, type)
      ext = ".#{ext}" unless ext.to_s[0] == ?.
      ::Rack::Mime::MIME_TYPES[ext.to_s] = type
    end

    # Convenience function to discover if a template exists for the requested renderer (haml, sass, etc)
    def template_exists?(path, renderer=nil)
      template_path = path.dup
      template_path << ".#{renderer}" if renderer
      File.readable? File.join(settings.views, template_path)
    end

    # Base case renderer (do nothing), Should be over-ridden
    module StaticRender
      def render_path(path, layout)
        if template_exists?(path, :erb)
          erb(path.to_sym, :layout => layout)
        else
          false
        end
      end
    end
    include StaticRender
    
    @@layout = nil
    def self.page(url, options={}, &block)
      layout = @@layout
      layout = options[:layout] if !options[:layout].nil?
      
      get(url) do
        return yield if block_given?
        process_request(layout)
      end
    end
    
    def self.with_layout(layout, &block)
      @@layout = layout
      class_eval(&block) if block_given?
    ensure
      @@layout = nil
    end

    # This will match all requests not overridden in the project's init.rb
    not_found do
      process_request
    end
    
    def self.enabled?(name)
      name = (name.to_s << "?").to_sym
      self.respond_to?(name) && self.send(name)
    end
    
    def enabled?(name)
      self.class.enabled?(name)
    end

  private
    def process_request(layout = :layout)
      # Normalize the path and add index if we're looking at a directory
      path = request.path
      path << settings.index_file if path.match(%r{/$})
      path.gsub!(%r{^/}, '')

      # If the enabled renderers succeed, return the content, mime-type and an HTTP 200
      if content = render_path(path, layout)
        content_type mime_type(File.extname(path)), :charset => 'utf-8'
        status 200
        content
      else
        status 404
      end
    end
  end
end

# Haml is required & includes helpers
require "middleman/haml"
require "middleman/sass"
require "middleman/helpers"
require "middleman/rack/static"
require "middleman/rack/sprockets"
require "middleman/rack/minify_javascript"
require "middleman/rack/minify_css"
require "middleman/rack/downstream"

class Middleman::Base
  helpers Middleman::Helpers
  
  # Features disabled by default
  enable :asset_host
  disable :slickmap
  disable :cache_buster
  disable :minify_css
  disable :minify_javascript
  disable :relative_assets
  disable :smush_pngs
  disable :automatic_image_sizes
  disable :relative_assets
  disable :cache_buster
  
  # Default build features
  configure :build do
  end
  
  # Check for and evaluate local configuration
  local_config = File.join(self.root, "init.rb")
  if File.exists? local_config
    puts "== Reading:  Local config" if logging?
    Middleman::Base.class_eval File.read(local_config)
    set :app_file, File.expand_path(local_config)
  end
  
  use Middleman::Rack::Static
  use Middleman::Rack::Sprockets
  use Middleman::Rack::MinifyJavascript
  use Middleman::Rack::MinifyCSS
  use Middleman::Rack::Downstream
  
  def self.new(*args, &block)
    # loop over enabled feature
    features.flatten.each do |feature_name|
      next unless send(:"#{feature_name}?")
      
      feature_path = "features/#{feature_name}"
      if File.exists? File.join(File.dirname(__FILE__), "#{feature_path}.rb")
        puts "== Enabling: #{feature_name.to_s.capitalize}" if logging?
        require "middleman/#{feature_path}"
      end
    end
    
    @@afters.each { |block| class_eval(&block) }
    
    super
  end
end