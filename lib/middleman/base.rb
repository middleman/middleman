# Be nice to other library systems, like the wonderful Rip
require 'rubygems' unless ENV['NO_RUBYGEMS']

# We're riding on Sinatra, so let's include it
require 'sinatra/base'

module Middleman
  class Base < Sinatra::Base
    set :app_file, __FILE__
    set :root, Dir.pwd
    set :reload, false
    set :logging, false
    set :environment, ENV['MM_ENV'] || :development
    set :supported_formats, %w(erb)
    set :index_file, "index.html"
    set :js_dir, "javascripts"
    set :css_dir, "stylesheets"
    set :images_dir, "images"
    set :build_dir, "build"
    set :http_prefix, "/"
    
    use Rack::ConditionalGet if environment == :development
    
    @@features = []
    
    def self.enable(*opts)
      @@features << opts
      super
    end
    
    def self.disable(*opts)
      @@features -= opts
      super
    end
    
    @@afters = []
    def self.after(&block)
      @@afters << block
    end
    
    # Rack helper for adding mime-types during local preview
    def self.mime(ext, type)
      ext = ".#{ext}" unless ext.to_s[0] == ?.
      ::Rack::Mime::MIME_TYPES[ext.to_s] = type
    end

    # Convenience function to discover if a tempalte exists for the requested renderer (haml, sass, etc)
    def template_exists?(path, renderer=nil)
      template_path = path.dup
      template_path << ".#{renderer}" if renderer
      File.exists? File.join(options.views, template_path)
    end

    # Base case renderer (do nothing), Should be over-ridden
    module StaticRender
      def render_path(path)
        if template_exists?(path, :erb)
          erb(path.to_sym)
        else
          false
        end
      end
    end
    include StaticRender

    # This will match all requests not overridden in the project's init.rb
    not_found do
      # Normalize the path and add index if we're looking at a directory
      path = request.path
      path << options.index_file if path.match(%r{/$})
      path.gsub!(%r{^/}, '')

      # If the enabled renderers succeed, return the content, mime-type and an HTTP 200
      if content = render_path(path)
        content_type media_type(File.extname(path)), :charset => 'utf-8'
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
require "sinatra/content_for"
require "middleman/helpers"
require "middleman/rack/static"
require "middleman/rack/sprockets"

class Middleman::Base
  helpers Sinatra::ContentFor
  helpers Middleman::Helpers
  
  use Middleman::Rack::Static
  use Middleman::Rack::Sprockets
  
  # Features disabled by default
  disable :slickmap
  disable :cache_buster
  disable :minify_css
  disable :minify_javascript
  disable :relative_assets
  disable :maruku
  disable :smush_pngs
  disable :automatic_image_sizes
  
  # Default build features
  configure :build do
    enable :minify_css
    enable :minify_javascript
    enable :cache_buster
  end
  
  def self.new(*args, &bk)
    # Check for and evaluate local configuration
    local_config = File.join(self.root, "init.rb")
    if File.exists? local_config
      puts "== Reading:  Local config" if logging?
      class_eval File.read(local_config)
      set :app_file, File.expand_path(local_config)
    end
    
    # loop over enabled feature
    @@features.flatten.each do |feature_name|
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