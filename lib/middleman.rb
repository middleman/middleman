require 'haml'
require 'compass' #must be loaded before sinatra
require 'sinatra/base'

# Sprockets ruby 1.9 hack
require File.join(File.dirname(__FILE__), 'middleman', 'sprockets_ext')

# Include content_for support
require File.join(File.dirname(__FILE__), '..', 'vendor', 'sinatra-content-for', 'lib', 'sinatra', 'content_for')

class Middleman < Sinatra::Base
  set :app_file, __FILE__
  set :static, true
  set :root, Dir.pwd
  set :environment, defined?(MIDDLEMAN_BUILDER) ? :build : :development
  
  set :supported_formats, %w(haml erb builder)
  
  helpers Sinatra::ContentFor

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
      config.sass_dir         = File.join(File.basename(self.views), "stylesheets")
      config.output_style     = :nested
      config.css_dir          = File.join(File.basename(self.public), "stylesheets")
      config.images_dir       = File.join(File.basename(self.public), "images")
      config.http_images_path = "/images"
      config.http_stylesheets_path = "/stylesheets"
      config.add_import_path(config.sass_dir)
    end
  end
  
  # include helpers
  class_eval File.read(File.join(File.dirname(__FILE__), 'middleman', 'helpers.rb'))
  
  # Check for local config
  local_config = File.join(self.root, "init.rb")
  if File.exists? local_config
    puts "== Local config at: #{local_config}"
    class_eval File.read(local_config)
  end
  
  configure do
    Compass.configure_sass_plugin!
  end
  
  # CSS files
  get %r{/(.*).css} do |path|
    content_type 'text/css', :charset => 'utf-8'
    begin
      location_of_sass_file = defined?(MIDDLEMAN_BUILDER) ? "build" : "views"
      css_filename = File.join(Dir.pwd, location_of_sass_file) + request.path_info
      sass(path.to_sym, Compass.sass_engine_options.merge({ :css_filename => css_filename }))
    rescue Exception => e
      sass_exception_string(e)
    end
  end
  
  # All other files
  get /(.*)/ do |path|
    path << "index.html" if path.match(%r{/$})
    path.gsub!(%r{^/}, '')
    path.gsub!(File.extname(path), '')
    
    result = nil
    begin
      options.supported_formats.detect do |renderer|
        next false if !File.exists?(File.join(options.views, "#{path}.#{renderer}"))
        result = send(renderer.to_sym, path.to_sym)
      end
    rescue Haml::Error => e
      result = "Haml Error: #{e}"
      result << "<pre>Backtrace: #{e.backtrace.join("\n")}</pre>"
    end
    
    result || pass
  end
end