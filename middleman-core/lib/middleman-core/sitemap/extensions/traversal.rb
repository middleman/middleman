module Middleman

  module Sitemap

    module Extensions

      module Traversal
        # This resource's parent resource
        # @return [Middleman::Sitemap::Resource, nil]
        def parent
          parts = path.split("/")
          parts.pop if path.include?(app.index_file)

          return nil if parts.length < 1

          parts.pop
          parts << app.index_file

          parent_path = "/" + parts.join("/")

          store.find_resource_by_destination_path(parent_path)
        end

        # This resource's child resources
        # @return [Array<Middleman::Sitemap::Resource>]
        def children
          return [] unless directory_index?

          if eponymous_directory?
            base_path = eponymous_directory_path
            prefix    = %r|^#{base_path.sub("/", "\\/")}|
          else
            base_path = path.sub("#{app.index_file}", "")
            prefix    = %r|^#{base_path.sub("/", "\\/")}|
          end

          store.resources.select do |sub_resource|
            if sub_resource.path == self.path || sub_resource.path !~ prefix
              false
            else
              inner_path = sub_resource.path.sub(prefix, "")
              parts = inner_path.split("/")
              if parts.length == 1
                true
              elsif parts.length == 2
                parts.last == app.index_file
              else
                false
              end
            end
          end
        end

        # This resource's sibling resources
        # @return [Array<Middleman::Sitemap::Resource>]
        def siblings
          return [] unless parent
          parent.children.reject { |p| p == self }
        end

        # Whether this resource either a directory index, or has the same name as an existing directory in the source
        # @return [Boolean]
        def directory_index?
          path.include?(app.index_file) || path =~ /\/$/ || eponymous_directory?
        end

        # Whether the resource has the same name as a directory in the source
        # (e.g., if the resource is named 'gallery.html' and a path exists named 'gallery/', this would return true)
        # @return [Boolean]
        def eponymous_directory?
          full_path = File.join(app.source_dir, eponymous_directory_path)
          !!(File.exists?(full_path) && File.directory?(full_path))
        end

        # The path for this resource if it were a directory, and not a file
        # (e.g., for 'gallery.html' this would return 'gallery/')
        # @return [String]
        def eponymous_directory_path
          path.sub(ext, '/').sub(/\/$/, "") + "/"
        end
      end
    end
  end
end
