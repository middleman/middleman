require 'middleman-core/template_context'

# Rendering extension
module Middleman
  module CoreExtensions
    module Rendering
      # Setup extension
      class << self
        # Once registered
        def included(app)
          app.define_hook :before_render
          app.define_hook :after_render

          ::Tilt.mappings.delete('html') # WTF, Tilt?
          ::Tilt.mappings.delete('csv')

          require 'active_support/core_ext/string/output_safety'

          # Activate custom renderers
          require 'middleman-core/renderers/erb'
          app.send :include, Middleman::Renderers::ERb

          # CoffeeScript Support
          begin
            require 'middleman-core/renderers/coffee_script'
            app.send :include, Middleman::Renderers::CoffeeScript
          rescue LoadError
          end

          # Haml Support
          begin
            require 'middleman-core/renderers/haml'
            app.send :include, Middleman::Renderers::Haml
          rescue LoadError
          end

          # Sass Support
          begin
            require 'middleman-core/renderers/sass'
            app.send :include, Middleman::Renderers::Sass
          rescue LoadError
          end

          # Markdown Support
          require 'middleman-core/renderers/markdown'
          app.send :include, Middleman::Renderers::Markdown

          # Liquid Support
          begin
            require 'middleman-core/renderers/liquid'
            Middleman::Extensions.register :liquid, Middleman::Renderers::Liquid, auto_activate: :before_configuration
          rescue LoadError
          end

          # Slim Support
          begin
            require 'middleman-core/renderers/slim'
            app.send :include, Middleman::Renderers::Slim
          rescue LoadError
          end

          # Less Support
          begin
            require 'middleman-core/renderers/less'
            app.send :include, Middleman::Renderers::Less
          rescue LoadError
          end

          # Stylus Support
          begin
            require 'middleman-core/renderers/stylus'
            app.send :include, Middleman::Renderers::Stylus
          rescue LoadError
          end

          # Clean up missing Tilt exts
          app.after_configuration do
            Tilt.mappings.each do |key, _|
              begin
                Tilt[".#{key}"]
              rescue LoadError, NameError
                Tilt.mappings.delete(key)
              end
            end
          end
        end
      end
    end
  end
end
