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
      config.images_dir       = File.join(File.basename(self.public), "images")
      config.http_images_path = "/images/"
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
  
  get /(.*)/ do |path|
    path << "index.html" if path.match(%r{/$})
    path.gsub!(%r{^/}, '')
    @template = path.gsub(File.extname(path), '').to_sym
    @full_request_path = path
    
    result = nil
    
    %w(haml erb builder maruku mab sass).each do |renderer|
      next if !File.exists?(File.join(options.views, "#{@template}.#{renderer}"))
      
      renderer = "markaby" if renderer == "mab"
      result = if renderer == "sass"
        content_type 'text/css', :charset => 'utf-8'
        begin
          sass(@template, Compass.sass_engine_options)
        rescue Exception => e
          sass_exception_string(e)
        end
      else
        send(renderer.to_sym, @template)
      end
      
      break
    end
    
    result || pass
  end

  # Handle Sass errors
  def sass_exception_string(e)
    e_string = "#{e.class}: #{e.message}"

    if e.is_a? Sass::SyntaxError
      e_string << "\non line #{e.sass_line}"

      if e.sass_filename
        e_string << " of #{e.sass_filename}"

        if File.exists?(e.sass_filename)
          e_string << "\n\n"

          min = [e.sass_line - 5, 0].max
          begin
            File.read(e.sass_filename).rstrip.split("\n")[
              min .. e.sass_line + 5
            ].each_with_index do |line, i|
              e_string << "#{min + i + 1}: #{line}\n"
            end
          rescue
            e_string << "Couldn't read sass file: #{e.sass_filename}"
          end
        end
      end
    end
    <<END
/*
#{e_string}

Backtrace:\n#{e.backtrace.join("\n")}
*/
body:before {
  white-space: pre;
  font-family: monospace;
  content: "#{e_string.gsub('"', '\"').gsub("\n", '\\A ')}"; }
END
  end
end

require File.join(File.dirname(__FILE__), 'middleman', 'helpers')