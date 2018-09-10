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
        def parent(_recurse = false)
          max_recursion = @app.config[:max_traversal_recursion] || 99
          _parent(path, max_recursion)
        end

        def _parent(_path, max_recursion)
          # What is the configured format for index pages.
          index_file = @app.config[:index_file]
          parts = _path.split('/')
          # Reduce the path by the current page to get the parent level path.
          current_page = parts.pop
          # Does the current page has the name of an index file?
          is_index = current_page == index_file
          # Is the `current_page` in the traversal root?
          # Note: `traversal_root` is `/` for non localised pages and `/[lang]/` for
          # localised pages.
          at_traversal_root = !(_path =~ /^#{traversal_root}#{current_page}$/).nil?

          # Check that we have any path parts left after the pop because if we
          # don't, `current_page` is either root or another file under root.
          # Also, if we are `at_traversal_root`, we consider this root.
          if parts.empty? || at_traversal_root
            # If this `is_index`, the `current_page` is root and there is no parent.
            if is_index
              return nil
            else
              # `current_page` must be a page under root, let's return the root
              # index page of the `traversal_root` (`/` or `/[lang]/`).
              return @store.find_resource_by_path("#{traversal_root}#{index_file}")
            end
          end

          # Get the index file for the parent path parts, e.g.: `/blog/index.html`
          # for `/blog/`.
          index_by_parts = proc do |parts|
            found = @store.find_resource_by_destination_path("#{parts.join('/')}/#{index_file}")
            return found unless found.nil?
          end

          # Get a file that has the name of the parent path parts e.g.:
          # `/blog.html` for `/blog/`.
          file_by_parts = proc do |parts|
            test_expr = Regexp.escape(parts.join('/'))
            # eponymous reverse-lookup
            found = @store.resources.find do |candidate|
              candidate.path =~ %r{^#{test_expr}(?:\.[a-zA-Z0-9]+|\/)$}
            end
            return found unless found.nil?
          end

          # Try to find a file matching the parent path name and return it.
          # E.g. `parts == ['en', 'blog']`, we try to find: `/en/blog.html`
          file_by_parts.call(parts)

          # Try to find an non-localised parent instead if `traversal_root`
          # indicates the path is localised and there are still more parts
          # remaining, and return it.
          # E.g. `parts == ['en', 'blog']`, we try to find: `/blog.html`
          if traversal_root != '/' && parts.length > 1
            file_by_parts.call(parts[1..-1])
          end

          # Now let's drop the last part of the path to try to find an index
          # file in the path above `current_page`'s path and return it.
          # E.g. `parts == ['en', 'blog']`, we try to find: `/en/index.html`
          parts.pop if is_index
          index_by_parts.call(parts)

          # Lastly, check for an non-localised index index file in the path
          # above `current_page`'s path and return it.
          # E.g. `parts == ['en', 'blog']`, we try to find: `/index.html`
          if traversal_root == "#{parts.first}/"
            index_by_parts.call(parts[1..-1] || '')
          end
          if !parts.empty? && max_recursion > 0
            return _parent parts.join('/'), max_recursion - 1
          end

          nil
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

          prefix = /^#{base_path.sub("/", "\\/")}/

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
