require 'set'

module Middleman

  module Sitemap

    module Extensions

      class OnDisk

        attr_accessor :sitemap
        attr_accessor :waiting_for_ready

        def initialize(sitemap)
          @sitemap = sitemap
          @app     = @sitemap.app
          @file_paths_on_disk = Set.new

          scoped_self = self
          @waiting_for_ready = true

          # Register file change callback
          @app.files.changed do |file|
            scoped_self.touch_file(file)
          end

          # Register file delete callback
          @app.files.deleted do |file|
            scoped_self.remove_file(file)
          end

          @app.ready do
            scoped_self.waiting_for_ready = false
            # Make sure the sitemap is ready for the first request
            sitemap.ensure_resource_list_updated!
          end
        end

        # Update or add an on-disk file path
        # @param [String] file
        # @return [Boolean]
        def touch_file(file, rebuild=true)
          return false if File.directory?(file)

          path = @sitemap.file_to_path(file)
          return false unless path

          ignored = @app.ignored_sitemap_matchers.any? do |name, callback|
            callback.call(file)
          end

          @file_paths_on_disk << file unless ignored

          # Rebuild the sitemap any time a file is touched
          # in case one of the other manipulators
          # (like asset_hash) cares about the contents of this file,
          # whether or not it belongs in the sitemap (like a partial)
          @sitemap.rebuild_resource_list!(:touched_file)

          unless waiting_for_ready || @app.build?
            # Force sitemap rebuild so the next request is ready to go.
            # Skip this during build because the builder will control sitemap refresh.
            @sitemap.ensure_resource_list_updated!
          end
        end

        # Remove a file from the store
        # @param [String] file
        # @return [void]
        def remove_file(file, rebuild=true)
          if @file_paths_on_disk.delete?(file)
            @sitemap.rebuild_resource_list!(:removed_file)
            unless waiting_for_ready || @app.build?
              # Force sitemap rebuild so the next request is ready to go.
              # Skip this during build because the builder will control sitemap refresh.
              @sitemap.ensure_resource_list_updated!
            end
          end
        end

        # Update the main sitemap resource list
        # @return [void]
        def manipulate_resource_list(resources)
          resources + @file_paths_on_disk.map do |file|
            ::Middleman::Sitemap::Resource.new(
              @sitemap,
              @sitemap.file_to_path(file),
              File.expand_path(file, @app.root)
            )
          end
        end
      end
    end
  end
end
