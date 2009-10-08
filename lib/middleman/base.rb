# Be nice to other library systems, like the wonderful Rip
require 'rubygems' unless ENV['NO_RUBYGEMS']

# We're riding on Sinatra, so let's include it
require 'sinatra/base'

module Middleman
  class Base < Sinatra::Base
    set :app_file, __FILE__
    set :root, Dir.pwd
    set :environment, ENV['MM_ENV'] || :development
    set :supported_formats, ["erb"]
    set :index_file, "index.html"
    set :js_dir, "javascripts"
    set :css_dir, "stylesheets"
    set :images_dir, "images"
    set :build_dir, "build"
    set :http_prefix, "/"

    # Features enabled by default
    enable :compass
    enable :content_for
    enable :sprockets
    
    # Features disabled by default
    disable :slickmap
    disable :cache_buster
    disable :minify_css
    disable :minify_javascript
    disable :relative_assets
    disable :markaby
    disable :maruku
    disable :smush_pngs
    
    # Default build features
    configure :build do
      enable :minify_css
      enable :minify_javascript
      enable :cache_buster
    end
  
    # Rack helper for adding mime-types during local preview
    def self.mime(ext, type)
      ext = ".#{ext}" unless ext.to_s[0] == ?.
      Rack::Mime::MIME_TYPES[ext.to_s] = type
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
  
    # Disable static asset handling in Rack, so we can customize it here
    disable :static
    
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
        # If no template handler renders the template, return the static file if it exists
        path = File.join(options.public, request.path)
        if !File.directory?(path) && File.exists?(path)
          status 200
          send_file(path)
        else
          status 404
        end
      end
    end
    
    # Copy, pasted & edited version of the setup in Sinatra.
    # Basically just changed the app's name and call out feature & configuration init.
    def self.run!(options={}, &block)
      init!
      set options
      handler      = detect_rack_handler
      handler_name = handler.name.gsub(/.*::/, '')
      puts "== The Middleman is standing watch on port #{port}"
      handler.run self, :Host => host, :Port => port do |server|
        trap(:INT) do
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
          puts "\n== The Middleman has ended his patrol"
        end
      
        if block_given?
          block.call
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
        end
      end
    rescue Errno::EADDRINUSE => e
      puts "== The Middleman is already standing watch on port #{port}!"
    end
    
    # Require the features for this project
    def self.init!(quiet=false)
      # Built-in helpers
      require 'middleman/helpers'
      helpers Middleman::Helpers

      # Haml is required & includes helpers
      require "middleman/features/haml"
      
      # Check for and evaluate local configuration
      local_config = File.join(self.root, "init.rb")
      if File.exists? local_config
        puts "== Local config at: #{local_config}" unless quiet
        class_eval File.read(local_config)
      end
      
      # loop over enabled feature
      features_path = File.expand_path("features/*.rb", File.dirname(__FILE__))
      Dir[features_path].each do |f|
        feature_name = File.basename(f, '.rb')
        option_name = :"#{feature_name}?"
        if respond_to?(option_name) && send(option_name) === true
          require "middleman/features/#{feature_name}"
        end
      end
    end
  end
end