require 'haml'
require 'compass' #must be loaded before sinatra
require 'sinatra/base'

require 'sprockets'
# Sprockets ruby 1.9 hack
require 'middleman/sprockets+ruby19'

require "yui/compressor"

# Include content_for support
require 'sinatra-content-for'

class Middleman < Sinatra::Base
  set :app_file, __FILE__
  set :static, true
  set :root, Dir.pwd
  set :environment, defined?(MIDDLEMAN_BUILDER) ? :build : :development
  set :default_ext, 'html'
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
  
  configure :build do
    Compass.configuration do |config|
      config.output_style = :compressed
    end
    
    module Minified
      module Javascript
        include ::Haml::Filters::Base
        def render_with_options(text, options)
          compressor = ::YUI::JavaScriptCompressor.new(:munge => true)
          data = compressor.compress(text)
          <<END
<script type=#{options[:attr_wrapper]}text/javascript#{options[:attr_wrapper]}>#{data.chomp}</script>
END
        end
      end
    end
  end
  
  # CSS files
  get %r{/(.*).css} do |path|
    content_type 'text/css', :charset => 'utf-8'
    begin
      static_version = File.join(Dir.pwd, 'public') + request.path_info
      send_file(static_version) if File.exists? static_version
      
      location_of_sass_file = defined?(MIDDLEMAN_BUILDER) ? "build" : "views"
      css_filename = File.join(Dir.pwd, location_of_sass_file) + request.path_info
      sass(path.to_sym, Compass.sass_engine_options.merge({ :css_filename => css_filename }))
    rescue Exception => e
      sass_exception_string(e)
    end
  end
  
  # All other files
  get /(.*)/ do |path|
    path << "index.#{options.default_ext}" if path.match(%r{/$})
    path.gsub!(%r{^/}, '')
    path_without_ext = path.gsub(File.extname(path), '')
    
    result = nil
    begin
      options.supported_formats.detect do |renderer|
        if File.exists?(File.join(options.views, "#{path}.#{renderer}"))
          result = send(renderer.to_sym, path.to_sym)
        elsif File.exists?(File.join(options.views, "#{path_without_ext}.#{renderer}"))
          result = send(renderer.to_sym, path_without_ext.to_sym)
        else
          false
        end
      end
    rescue Haml::Error => e
      result = "Haml Error: #{e}"
      result << "<pre>Backtrace: #{e.backtrace.join("\n")}</pre>"
    end
    
    result || pass
  end
  
  get %r{/(.*\.xml)} do |path|
    content_type 'text/xml', :charset => 'utf-8'
    haml(path.to_sym, :layout => false)
  end
end