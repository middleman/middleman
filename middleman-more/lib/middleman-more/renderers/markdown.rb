module Middleman
  module Renderers
    
    # Markdown renderer
    module Markdown

      # Setup extension
      class << self
    
        # Once registered
        def registered(app)
          # Set our preference for a markdown engine
          # TODO: Find a JRuby-compatible version
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

            # Look for the user's preferred engine
            unless markdown_engine.nil?
              
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

              if markdown_engine == :redcarpet
                # Forcably disable Redcarpet1 support.
                # Tilt defaults to this if available, but the compat
                # layer disables extensions.
                Object.send(:remove_const, :RedcarpetCompat) if defined? ::RedcarpetCompat
              end
            end
          end
        end
    
        alias :included :registered
      end
    end
  end
end
