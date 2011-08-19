require "sprockets"
  
module Middleman::CoreExtensions::Sprockets
  class << self
    def registered(app)
      app.set :js_compressor, false

      app.after_configuration do
        app.map "/#{app.js_dir}" do
          run Middleman::CoreExtensions::Sprockets::JavascriptEnvironment.new(app)
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
      
      # jQuery for Sprockets
      # begin
      #   require "jquery-rails"
      #   jquery-rails / vendor / assets / javascripts
      # rescue LoadError
      # end
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