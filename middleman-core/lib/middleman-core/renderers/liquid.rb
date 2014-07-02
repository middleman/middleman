# Require Gem
require 'liquid'

module Middleman
  module Renderers
    # Liquid Renderer
    class Liquid < Middleman::Extension
      # After config, setup liquid partial paths
      def after_configuration
        ::Liquid::Template.file_system = ::Liquid::LocalFileSystem.new(app.source_dir)
      end

      def manipulate_resource_list(resources)
        resources.each do |resource|
          next unless resource.source_file =~ %r{\.liquid$}

          # Convert data object into a hash for liquid
          resource.add_metadata locals: { data: app.data.to_h }
        end
      end
    end
  end
end
