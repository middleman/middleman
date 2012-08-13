module Middleman
  module Renderers

    # Markdown renderer
    module Markdown

      # Setup extension
      class << self

        # Once registered
        def registered(app)
          # Set our preference for a markdown engine
          app.set :markdown_engine, :maruku
          app.set :markdown_engine_prefix, ::Tilt

          app.before_configuration do
            template_extensions :markdown => :html,
                                :mdown    => :html,
                                :md       => :html,
                                :mkd      => :html,
                                :mkdn     => :html
          end

          # Once configuration is parsed
          app.after_configuration do

            begin
              # Look for the user's preferred engine
              if markdown_engine == :redcarpet
                require "middleman-core/renderers/redcarpet"
                ::Tilt.prefer(::Middleman::Renderers::RedcarpetTemplate)
              elsif !markdown_engine.nil?
                # Map symbols to classes
                markdown_engine_klass = if markdown_engine.is_a? Symbol
                  engine = markdown_engine.to_s
                  engine = engine == "rdiscount" ? "RDiscount" : engine.camelize
                  markdown_engine_prefix.const_get("#{engine}Template")
                else
                  markdown_engine_prefix
                end

                # Tell tilt to use that engine
                ::Tilt.prefer(markdown_engine_klass)
              end
            rescue LoadError
              logger.warn "Requested Markdown engine (#{markdown_engine}) not found. Maybe the gem needs to be installed and required?"
            end
          end
        end

        alias :included :registered
      end
    end

  end
end
