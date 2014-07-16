# Require Gem
require 'liquid'

module Middleman
  module Renderers
    # Liquid Renderer
    class Liquid < Middleman::Extension
      # After config, setup liquid partial paths
      def after_configuration
        ::Liquid::Template.file_system = self
      end

      # Called by Liquid to retrieve a template file
      def read_template_file(template_path, _)
        file = app.files.find(:source, "_#{template_path}.liquid")
        raise ::Liquid::FileSystemError, "No such template '#{template_path}'" unless file
        File.read(file[:full_path])
      end

      # @return Array<Middleman::Sitemap::Resource>
      Contract ResourceList => ResourceList
      def manipulate_resource_list(resources)
        return resources unless app.extensions[:data]

        resources.each do |resource|
          next if resource.source_file.nil?
          next unless resource.source_file[:relative_path].to_s =~ %r{\.liquid$}

          # Convert data object into a hash for liquid
          resource.add_metadata locals: { data: app.extensions[:data].data_store.to_h }
        end
      end
    end
  end
end
