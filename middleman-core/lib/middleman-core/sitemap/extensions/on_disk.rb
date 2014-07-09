require 'set'
require 'middleman-core/contracts'

module Middleman
  module Sitemap
    module Extensions
      class OnDisk < Extension
        attr_accessor :waiting_for_ready

        def initialize(app, config={}, &block)
          super

          @file_paths_on_disk = Set.new

          scoped_self = self
          @waiting_for_ready = true

          @app.ready do
            scoped_self.waiting_for_ready = false
            # Make sure the sitemap is ready for the first request
            sitemap.ensure_resource_list_updated!
          end
        end

        Contract None => Any
        def before_configuration
          file_watcher.changed(&method(:touch_file))
          file_watcher.deleted(&method(:remove_file))
        end

        # Update or add an on-disk file path
        # @param [String] file
        # @return [void]
        Contract String => Any
        def touch_file(file)
          return false if File.directory?(file)

          begin
            @app.sitemap.file_to_path(file)
          rescue
            return
          end

          ignored = @app.config[:ignored_sitemap_matchers].any? do |_, callback|
            if callback.arity == 1
              callback.call(file)
            else
              callback.call(file, @app)
            end
          end

          @file_paths_on_disk << file unless ignored

          # Rebuild the sitemap any time a file is touched
          # in case one of the other manipulators
          # (like asset_hash) cares about the contents of this file,
          # whether or not it belongs in the sitemap (like a partial)
          @app.sitemap.rebuild_resource_list!(:touched_file)

          # Force sitemap rebuild so the next request is ready to go.
          # Skip this during build because the builder will control sitemap refresh.
          @app.sitemap.ensure_resource_list_updated! unless waiting_for_ready || @app.build?
        end

        # Remove a file from the store
        # @param [String] file
        # @return [void]
        Contract String => Any
        def remove_file(file)
          return unless @file_paths_on_disk.delete?(file)

          @app.sitemap.rebuild_resource_list!(:removed_file)

          # Force sitemap rebuild so the next request is ready to go.
          # Skip this during build because the builder will control sitemap refresh.
          @app.sitemap.ensure_resource_list_updated! unless waiting_for_ready || @app.build?
        end

        # Update the main sitemap resource list
        # @return Array<Middleman::Sitemap::Resource>
        Contract ResourceList => ResourceList
        def manipulate_resource_list(resources)
          resources + @file_paths_on_disk.map do |file|
            ::Middleman::Sitemap::Resource.new(
              @app.sitemap,
              @app.sitemap.file_to_path(file),
              File.join(@app.root, file)
            )
          end
        end
      end
    end
  end
end
