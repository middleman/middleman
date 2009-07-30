require 'rubygems'
require 'haml'
require 'compass' #must be loaded before sinatra
require 'sinatra/base'

# Include markaby support
require File.join(File.dirname(__FILE__), '..', 'vendor', 'sinatra-markaby', 'lib', 'sinatra', 'markaby')

# Include maruku support
require File.join(File.dirname(__FILE__), '..', 'vendor', 'sinatra-maruku', 'lib', 'sinatra', 'maruku')

# Include content_for support
require File.join(File.dirname(__FILE__), '..', 'vendor', 'sinatra-content-for', 'lib', 'sinatra', 'content_for')

class Middleman < Sinatra::Base
  set :app_file, __FILE__
  set :static, true
  set :root, Dir.pwd
  set :environment, defined?(MIDDLEMAN_BUILDER) ? :build : :development
    
  helpers Sinatra::Markaby
  helpers Sinatra::Maruku
  helpers Sinatra::ContentFor
  
  helpers do
    def link_to(title, url="#", params={})
      params = params.map { |k,v| %Q{#{k}="#{v}"}}.join(' ')
      %Q{<a href="#{url}" #{params}>#{title}</a>}
    end
    
    def page_classes(*additional)
      classes = []
      parts = @full_request_path.split('.')[0].split('/')
      parts.each_with_index { |path, i| classes << parts.first(i+1).join('_') }
    
      classes << "index" if classes.empty?
      classes += additional unless additional.empty?
      classes.join(' ')
    end
    
    def sprite(name)
      image_tag("spacer.gif", :class => "#{name}-img")
    end
  end
  
  def self.run!(options={}, &block)
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
  
  configure do
    Compass.configuration do |config|
      config.project_path     = Dir.pwd
      config.sass_dir         = File.join(File.expand_path(self.views), "stylesheets")
      config.output_style     = :nested
      config.images_dir       = File.join(File.basename(self.public), "images")
      config.http_images_path = "/images/"
    end
  end
  
  # Check for local config
  local_config = File.join(self.root, "init.rb")
  if File.exists? local_config
    puts "== Local config at: #{local_config}"
    class_eval File.read(local_config)
  end
  
  get /(.*)/ do |path|
    path << "index.html" if path.match(%r{/$})
    path.gsub!(%r{^/}, '')
    template = path.gsub(File.extname(path), '').to_sym
    @full_request_path = path
    
    result = nil
    
    %w(haml erb builder maruku mab sass).each do |renderer|
      next if !File.exists?(File.join(options.views, "#{template}.#{renderer}"))
      
      renderer = "markaby" if renderer == "mab"
      result = if renderer == "sass"
        content_type 'text/css', :charset => 'utf-8'
        sass(template, Compass.sass_engine_options)
      else
        send(renderer.to_sym, template)
      end
      
      break
    end
    
    result || pass
  end
end