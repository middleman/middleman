require 'rubygems' unless ENV['NO_RUBYGEMS']
require 'haml'
require 'sinatra/base'
require 'middleman/helpers'

def mime(ext, type)
  ext = ".#{ext}" unless ext.to_s[0] == ?.
  Rack::Mime::MIME_TYPES[ext.to_s] = type
end

module Middleman
  class Base < Sinatra::Base
    set :app_file, __FILE__
    set :root, Dir.pwd
    set :environment, ENV['MM_ENV'] || :development
    set :supported_formats, []
    set :index_file, 'index.html'
    set :css_dir, "stylesheets"
    set :images_dir, "images"
    set :build_dir, "build"

    enable :compass
    enable :content_for
    enable :sprockets
    #enable :slickmap
    disable :cache_buster
    disable :minify_css
    disable :minify_javascript
    disable :relative_assets
    disable :markaby
    disable :maruku
    
    # include helpers
    helpers Middleman::Helpers
    
    # Default build features
    configure :build do
      enable :minify_css
      enable :minify_javascript
      enable :cache_buster
      # disable :slickmap
    end
  
    def template_exists?(path, renderer=nil)
      template_path = path.dup
      template_path << ".#{renderer}" if renderer
      File.exists? File.join(options.views, template_path)
    end
    
    # Base case renderer (do nothing), Should be over-ridden
    module StaticRender
      def render_path(path)
        false
      end
    end
    include StaticRender
  
    # All other files
    disable :static
    not_found do
      path = request.path
      path << options.index_file if path.match(%r{/$})
      path.gsub!(%r{^/}, '')
    
      if content = render_path(path)
        content_type media_type(File.extname(path)), :charset => 'utf-8'
        status 200
        content
      else
        # Otherwise, send the static file
        path = File.join(options.public, request.path)
        if File.exists?(path)
          status 200
          send_file(path)
        else
          status 404
        end
      end
    end
    
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
    
    def self.init!
      # Check for local config
      local_config = File.join(self.root, "init.rb")
      if File.exists? local_config
        puts "== Local config at: #{local_config}"
        class_eval File.read(local_config)
      end

      require "middleman/features/haml"
      
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