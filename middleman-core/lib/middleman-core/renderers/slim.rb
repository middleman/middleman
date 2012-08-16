# Load gem
require "slim"

module Middleman
  module Renderers

    # Slim renderer
    module Slim

      # Setup extension
      class << self

        # Once registered
        def registered(app)
          app.before_configuration do
            template_extensions :slim => :html
          end

          # Setup Slim options to work with partials
          ::Slim::Engine.set_default_options(
            :buffer    => '@_out_buf',
            :generator => ::Temple::Generators::StringBuffer
          )
          
          app.after_configuration do
            sass_context_hack = {
              :context => self
            }
            ::Slim::EmbeddedEngine.default_options[:sass] = sass_context_hack
            ::Slim::EmbeddedEngine.default_options[:scss] = sass_context_hack
          end
        end

        alias :included :registered
      end
    end
  end
end
