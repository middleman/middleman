# Require Gem
require "liquid"

module Middleman
  module Renderers

    # Liquid Renderer
    module Liquid

      # Setup extension
      class << self

        # Once registerd
        def registered(app)
          app.before_configuration do
            template_extensions :liquid => :html
          end

          # After config, setup liquid partial paths
          app.after_configuration do
            ::Liquid::Template.file_system = ::Liquid::LocalFileSystem.new(source_dir)

            # Convert data object into a hash for liquid
            sitemap.provides_metadata %r{\.liquid$} do |path|
              { :locals => { :data => data.to_h } }
            end
          end
        end

        alias :included :registered
      end
    end

  end
end
