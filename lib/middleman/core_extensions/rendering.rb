require "padrino-core/application/rendering"

module Middleman::CoreExtensions::Rendering
  class << self
    def registered(app)
      app.extend ClassMethods
      app.send :include, InstanceMethods
      
      # Tilt-aware renderer
      app.register Padrino::Rendering

      # Activate custom renderers
      app.register Middleman::Renderers::Sass
      app.register Middleman::Renderers::Markdown
      app.register Middleman::Renderers::ERb
      app.register Middleman::Renderers::CoffeeScript
      app.register Middleman::Renderers::Liquid
    end
    alias :included :registered
  end
  
  module ClassMethods
    def extensionless_path(file)
      @_extensionless_path_cache ||= {}
      
      if @_extensionless_path_cache.has_key?(file)
        @_extensionless_path_cache[file]
      else
        path = file.dup
        end_of_the_line = false
        while !end_of_the_line
          file_extension = File.extname(path)
    
          if ::Tilt.mappings.has_key?(file_extension.gsub(/^\./, ""))
            path = path.sub(file_extension, "")
          else
            end_of_the_line = true
          end
        end
        
        @_extensionless_path_cache[file] = path
        path
      end
    end
  end
  
  module InstanceMethods
    def extensionless_path(path)
      settings.extensionless_path(path)
    end
  end
end