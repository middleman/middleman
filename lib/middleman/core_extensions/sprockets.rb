require 'pathname'
require 'rbconfig'
require "sprockets"

module Middleman::CoreExtensions::Sprockets
  class << self
    def registered(app)
      app.set :js_compressor, false

      app.after_configuration do
        js_env = Middleman::CoreExtensions::Sprockets::JavascriptEnvironment.new(app)
        
        js_dir = File.join("vendor", "assets", "javascripts")
        gems_with_js = ::Middleman.rubygems_latest_specs.select do |spec|
          ::Middleman.spec_has_file?(spec, js_dir)
        end.each do |spec|
          js_env.append_path File.join(spec.full_gem_path, js_dir)
        end
        
        # add paths to js_env (vendor/assets/javascripts)
        app.map "/#{app.js_dir}" do
          run js_env
        end
        
        # app.map "/#{app.css_dir}" do
        #   run Middleman::CoreExtensions::Sprockets::StylesheetEnvironment.new(app)
        # end
      end
    end
    alias :included :registered
  end

  class MiddlemanEnvironment < ::Sprockets::Environment
    def initialize(app)
      full_path = app.views
      full_path = File.join(app.root, app.views) unless app.views.include?(app.root)
      
      super File.expand_path(full_path)
    end
  end
    
  class JavascriptEnvironment < MiddlemanEnvironment
    def initialize(app)
      super

      # Disable css
      unregister_processor "text/css", ::Sprockets::DirectiveProcessor
      
      self.js_compressor = app.settings.js_compressor

      # configure search paths
      append_path app.js_dir
    end
    
    def javascript_exception_response(exception)
      expire_index!
      super(exception)
    end
  end
  
  # class StylesheetEnvironment < MiddlemanEnvironment
  #   def initialize(app)
  #     super
  # 
  #     # Disable js
  #     unregister_processor "application/javascript", ::Sprockets::DirectiveProcessor
  # 
  #     # configure search paths
  #     stylesheets_path = File.join(File.expand_path(app.views), app.css_dir)
  #     append_path stylesheets_path
  #   end
  #
  #   def css_exception_response(exception)
  #     expire_index!
  #     super(exception)
  #   end
  # end
end