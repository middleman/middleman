module Middleman
  module Renderers
    # Markdown renderer
    module Markdown
      # Setup extension
      class << self
        # Once registered
        def registered(app)
          # Set our preference for a markdown engine
          app.config.define_setting :markdown_engine, :kramdown, 'Preferred markdown engine'
          app.config.define_setting :markdown_engine_prefix, ::Tilt, 'The parent module for markdown template engines'

          app.before_configuration do
            template_extensions markdown: :html,
                                mdown: :html,
                                md: :html,
                                mkd: :html,
                                mkdn: :html
          end

          # Once configuration is parsed
          app.after_configuration do
            markdown_exts = %w(markdown mdown md mkd mkdn)

            begin
              # Look for the user's preferred engine
              if config[:markdown_engine] == :redcarpet
                require 'middleman-core/renderers/redcarpet'
                ::Tilt.prefer(::Middleman::Renderers::RedcarpetTemplate, *markdown_exts)
                MiddlemanRedcarpetHTML.middleman_app = self
              elsif config[:markdown_engine] == :kramdown
                require 'middleman-core/renderers/kramdown'
                ::Tilt.prefer(::Middleman::Renderers::KramdownTemplate, *markdown_exts)
                MiddlemanKramdownHTML.middleman_app = self
              elsif config[:markdown_engine]
                # Map symbols to classes
                markdown_engine_klass = if config[:markdown_engine].is_a? Symbol
                  engine = config[:markdown_engine].to_s
                  engine = engine == 'rdiscount' ? 'RDiscount' : engine.camelize
                  config[:markdown_engine_prefix].const_get("#{engine}Template")
                else
                  config[:markdown_engine_prefix]
                end

                # Tell tilt to use that engine
                ::Tilt.prefer(markdown_engine_klass, *markdown_exts)
              end
            rescue LoadError
              # If they just left it at the default engine and don't happen to have it,
              # then they're using middleman-core bare and we shouldn't bother them.
              if config.setting(:markdown_engine).value_set?
                logger.warn "Requested Markdown engine (#{config[:markdown_engine]}) not found. Maybe the gem needs to be installed and required?"
              end
            end
          end
        end

        alias_method :included, :registered
      end
    end
  end
end
