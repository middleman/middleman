# Load gem
require 'slim'

module SafeTemplate
  def render(*)
    super.html_safe
  end
end

class Slim::Template
  include SafeTemplate

  def precompiled_preamble(locals)
    "__in_slim_template = true\n" << super
  end
end

module Middleman
  module Renderers
    # Slim renderer
    module Slim
      # Setup extension
      class << self
        # Once registered
        def registered(app)
          app.before_configuration do
            template_extensions slim: :html
          end

          # Setup Slim options to work with partials
          ::Slim::Engine.set_options(
            buffer: '@_out_buf',
            use_html_safe: true,
            generator: ::Temple::Generators::RailsOutputBuffer,
            disable_escape: true
          )

          app.after_configuration do
            context_hack = {
              context: self
            }

            ::Slim::Embedded::SassEngine.disable_option_validator!
            %w(sass scss markdown).each do |engine|
              ::Slim::Embedded.options[engine.to_sym] = context_hack
            end
          end
        end

        alias_method :included, :registered
      end
    end
  end
end
