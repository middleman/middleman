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
      def read_template_file(template_path)
        file = app.files.find(:source, "_#{template_path}.liquid")
        raise ::Liquid::FileSystemError, "No such template '#{template_path}'" unless file

        file.read
      end

      Contract IsA['Middleman::Sitemap::ResourceListContainer'] => Any
      def manipulate_resource_list_container!(resource_list)
        return unless app.extensions[:data]

        resource_list.by_source_extension('.liquid').each do |resource|
          # Convert data object into a hash for liquid
          resource.add_metadata locals: {
            data: stringify_recursive(app.extensions[:data].data_store.to_h)
          }
        end
      end

      def stringify_recursive(hash)
        {}.tap do |h|
          hash.each { |key, value| h[key.to_s] = map_value(value) }
        end
      end

      def map_value(thing)
        case thing
        when Hash
          stringify_recursive(thing)
        when Array
          thing.map { |v| map_value(v) }
        else
          thing
        end
      end
    end
  end
end
