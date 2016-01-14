module Middleman
  module Sitemap
    module Extensions
      module Traversal
        def traversal_root
          root = if !@app.extensions[:i18n]
            '/'
          else
            @app.extensions[:i18n].path_root(::I18n.locale)
          end

          root.sub(/^\//, '')
        end

        # This resource's parent resource
        # @return [Middleman::Sitemap::Resource, nil]
        def parent
          root = path.sub(/^#{::Regexp.escape(traversal_root)}/, '')
          parts = root.split('/')

          tail = parts.pop
          is_index = (tail == @app.config[:index_file])

          if parts.empty?
            return is_index ? nil : @store.find_resource_by_path(@app.config[:index_file])
          end

          test_expr = parts.join('\\/')
          # eponymous reverse-lookup
          found = @store.resources.find do |candidate|
            candidate.path =~ %r{^#{test_expr}(?:\.[a-zA-Z0-9]+|\/)$}
          end

          if found
            found
          else
            parts.pop if is_index
            @store.find_resource_by_destination_path("#{parts.join('/')}/#{@app.config[:index_file]}")
          end
        end

        # This resource's child resources
        # @return [Array<Middleman::Sitemap::Resource>]
        def children
          return [] unless directory_index?

          base_path = if eponymous_directory?
            eponymous_directory_path
          else
            path.sub(@app.config[:index_file].to_s, '')
          end

          prefix = %r{^#{base_path.sub("/", "\\/")}}

          @store.resources.select do |sub_resource|
            if sub_resource.path == path || sub_resource.path !~ prefix
              false
            else
              inner_path = sub_resource.path.sub(prefix, '')
              parts = inner_path.split('/')
              if parts.length == 1
                true
              elsif parts.length == 2
                parts.last == @app.config[:index_file]
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

        # Whether this resource is either a directory index, or has the same name as an existing directory in the source
        # @return [Boolean]
        def directory_index?
          path.include?(@app.config[:index_file]) || path =~ /\/$/ || eponymous_directory?
        end

        # Whether the resource has the same name as a directory in the source
        # (e.g., if the resource is named 'gallery.html' and a path exists named 'gallery/', this would return true)
        # @return [Boolean]
        def eponymous_directory?
          if !path.end_with?("/#{@app.config[:index_file]}") && destination_path.end_with?("/#{@app.config[:index_file]}")
            return true
          end

          @app.files.by_type(:source).watchers.any? do |source|
            (source.directory + Pathname(eponymous_directory_path)).directory?
          end
        end

        # The path for this resource if it were a directory, and not a file
        # (e.g., for 'gallery.html' this would return 'gallery/')
        # @return [String]
        def eponymous_directory_path
          path.sub(ext, '/').sub(/\/$/, '') + '/'
        end
      end
    end
  end
end
