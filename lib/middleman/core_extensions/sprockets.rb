require "sprockets"

module Middleman::CoreExtensions::Sprockets
  class << self
    def registered(app)
      app.set :js_compressor, false
      
      app.map "/#{app.js_dir}" do
        run JavascriptEnvironment.new(app)
      end
      # app.map "/#{app.css_dir}" do
      #   run StylesheetEnvironment.new(app)
      # end
    end
    alias :included :registered
  end

  class MiddlemanEnvironment < Sprockets::Environment
    def initialize(app)
      super File.expand_path(app.views)
    end
  end
    
  class JavascriptEnvironment < MiddlemanEnvironment
    def initialize(app)
      super

      # Disable css
      unregister_processor "text/css", ::Sprockets::DirectiveProcessor
      
      self.js_compressor = app.settings.js_compressor

      # configure search paths
      javascripts_path = File.join(File.expand_path(app.views), app.js_dir)
      append_path javascripts_path
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
  # end
end