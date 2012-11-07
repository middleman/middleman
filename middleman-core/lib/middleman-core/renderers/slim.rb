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
            context_hack = {
              :context => self
            }
            %w(sass scss markdown).each do |engine|
              ::Slim::EmbeddedEngine.default_options[engine.to_sym] = context_hack
            end
          end
        end

        alias :included :registered
      end
    end
  end
end
