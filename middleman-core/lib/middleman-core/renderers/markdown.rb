module Middleman
  module Renderers
    # Markdown renderer
    class Markdown < ::Middleman::Extension
      define_setting :markdown_engine, :kramdown, 'Preferred markdown engine'
      define_setting :markdown_engine_prefix, ::Tilt, 'The parent module for markdown template engines'

      # Once configuration is parsed
      def after_configuration
        markdown_exts = %w(markdown mdown md mkd mkdn)

        begin
          # Look for the user's preferred engine
          if app.config[:markdown_engine] == :redcarpet
            require 'middleman-core/renderers/redcarpet'
            ::Tilt.prefer(::Middleman::Renderers::RedcarpetTemplate, *markdown_exts)
          elsif app.config[:markdown_engine] == :kramdown
            require 'middleman-core/renderers/kramdown'
            ::Tilt.prefer(::Middleman::Renderers::KramdownTemplate, *markdown_exts)
          elsif app.config[:markdown_engine]
            # Map symbols to classes
            markdown_engine_klass = if app.config[:markdown_engine].is_a? Symbol
              engine = app.config[:markdown_engine].to_s
              engine = engine == 'rdiscount' ? 'RDiscount' : engine.camelize
              app.config[:markdown_engine_prefix].const_get("#{engine}Template")
            else
              app.config[:markdown_engine_prefix]
            end

            # Tell tilt to use that engine
            ::Tilt.prefer(markdown_engine_klass, *markdown_exts)
          end
        rescue LoadError
          # If they just left it at the default engine and don't happen to have it,
          # then they're using middleman-core bare and we shouldn't bother them.
          if app.config.setting(:markdown_engine).value_set?
            logger.warn "Requested Markdown engine (#{app.config[:markdown_engine]}) not found. Maybe the gem needs to be installed and required?"
          end
        end
      end
    end
  end
end
