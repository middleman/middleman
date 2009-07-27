require 'rubygems'
require 'haml'
require 'compass' #must be loaded before sinatra
require 'sinatra/base'

class Middleman < Sinatra::Base
  set :app_file, __FILE__
  
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
      config.images_dir       = File.join(File.expand_path(self.public), "images")
      config.http_images_path = "/images/"
    end
  end
  
  def render_haml_or_sass(path)
    if path.match /.html$/
      haml(path.gsub('.html', '').to_sym)
    elsif path.match /.css$/
      content_type 'text/css', :charset => 'utf-8'
      sass(path.gsub('.css', '').to_sym, Compass.sass_engine_options)
    end
  end
  
  get /(.*)/ do |path|
    path = path.gsub(%r{^/}, '')
    path = "index.html" if path == ''
    
    if path.match /.html$/
      haml(path.gsub('.html', '').to_sym)
    elsif path.match /.css$/
      content_type 'text/css', :charset => 'utf-8'
      sass(path.gsub('.css', '').to_sym, Compass.sass_engine_options)
    else
      pass
    end
  end
end