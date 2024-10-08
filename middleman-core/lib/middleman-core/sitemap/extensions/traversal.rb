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

          is_index = if @app.config[:traversal_use_any_index]
            tail.start_with?("index.")
          else
            tail == @app.config[:index_file]
          end

          if parts.empty?
            return nil if is_index 

             if @app.config[:traversal_use_any_index]
              return @store.find_index_resources_by_prefix("").first
            else
              return @store.find_resource_by_path(@app.config[:index_file])
            end
          end

          test_expr = parts.join('\\/')
          test_expr = %r{^#{test_expr}(?:\.[a-zA-Z0-9]+|\/)$}

          # eponymous reverse-lookup
          found = @store.resources.find do |candidate|
            candidate.path =~ test_expr
          end

          if found
            found
          else
            parts.pop if is_index

            if @app.config[:traversal_use_any_index]
              @store.find_index_resources_by_prefix(parts.join('/')).first
            else
              @store.find_resource_by_destination_path("#{parts.join('/')}/#{@app.config[:index_file]}")
            end
          end
        end

        # This resource's child resources
        # @return [Array<Middleman::Sitemap::Resource>]
        def children
          return [] unless directory_index?

          base_path = if eponymous_directory?
            eponymous_directory_path
          else
            if @app.config[:traversal_use_any_index]
              parts = path.split("/")
              filename = parts.pop

              if !filename.start_with?("index.")
                parts << filename
              end

              parts.join("/") + "/"
            else
              path.sub(@app.config[:index_file].to_s, '')
            end
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
                if @app.config[:traversal_use_any_index]
                  parts.last.start_with?("index.")
                else
                  parts.last == @app.config[:index_file]
                end
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
          if @app.config[:traversal_use_any_index]
            parts = path.split("/")
            filename = parts.pop

            filename.start_with?("index.") || path =~ /\/$/ || eponymous_directory?
          else
            path.include?(@app.config[:index_file]) || path =~ /\/$/ || eponymous_directory?
          end
        end

        # Whether the resource has the same name as a directory in the source
        # (e.g., if the resource is named 'gallery.html' and a path exists named 'gallery/', this would return true)
        # @return [Boolean]
        def eponymous_directory?
          if @app.config[:traversal_use_any_index]
            parts1 = path.split("/")
            filename1 = parts1.pop
          
            parts2 = destination_path.split("/")
            filename2 = parts2.pop

            if !filename1.start_with?("index.") && destination_path.start_with?("index.")
              return true
            end
          else
            if !path.end_with?("/#{@app.config[:index_file]}") && destination_path.end_with?("/#{@app.config[:index_file]}")
              return true
            end
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
