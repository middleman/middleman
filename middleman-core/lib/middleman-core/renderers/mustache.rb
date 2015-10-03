# Require Gem
require 'tilt-mustache'

module Middleman
  module Renderers
    # Liquid Renderer
    module Mustache
      # Setup extension
      class << self
        # Once registerd
        def registered(app)
          require 'mustache'

          app.before_configuration do
            template_extensions mustache: :html
          end

          # After config, setup liquid partial paths
          app.after_configuration do
            ::Mustache.template_path = source_dir

            # Convert data object into a hash for mustache
            sitemap.provides_metadata %r{\.mustache$} do
              { locals: { data: data.to_h }}
            end
          end
        end

        alias_method :included, :registered
      end
    end
  end
end
