# Used for merging results of metadata callbacks
require 'active_support/core_ext/hash/deep_merge'
require 'monitor'
require 'middleman-core/sitemap/queryable'

module Middleman
  # Sitemap namespace
  module Sitemap
    # The Store class
    #
    # The Store manages a collection of Resource objects, which represent
    # individual items in the sitemap. Resources are indexed by "source path",
    # which is the path relative to the source directory, minus any template
    # extensions. All "path" parameters used in this class are source paths.
    class Store
      # @return [Middleman::Application]
      attr_accessor :app

      include ::Middleman::Sitemap::Queryable::API

      # Initialize with parent app
      # @param [Middleman::Application] app
      def initialize(app)
        @app = app
        @resources = []
        @_cached_metadata = {}
        @resource_list_manipulators = []
        @needs_sitemap_rebuild = true
        @lock = Monitor.new

        reset_lookup_cache!

        # Register classes which can manipulate the main site map list
        register_resource_list_manipulator(:on_disk, Middleman::Sitemap::Extensions::OnDisk.new(self))

        # Request Endpoints
        register_resource_list_manipulator(:request_endpoints, @app.endpoint_manager)

        # Proxies
        register_resource_list_manipulator(:proxies, @app.proxy_manager)

        # Redirects
        register_resource_list_manipulator(:redirects, @app.redirect_manager)
      end

      # Register a klass which can manipulate the main site map list. Best to register
      # these in a before_configuration or after_configuration hook.
      #
      # @param [Symbol] name Name of the manipulator for debugging
      # @param [Class, Module] inst Abstract namespace which can update the resource list
      # @return [void]
      def register_resource_list_manipulator(name, inst, *)
        @resource_list_manipulators << [name, inst]
        rebuild_resource_list!(:registered_new)
      end

      # Rebuild the list of resources from scratch, using registed manipulators
      # rubocop:disable UnusedMethodArgument
      # @return [void]
      def rebuild_resource_list!(reason=nil)
        @lock.synchronize do
          @needs_sitemap_rebuild = true
        end
      end

      # Find a resource given its original path
      # @param [String] request_path The original path of a resource.
      # @return [Middleman::Sitemap::Resource]
      def find_resource_by_path(request_path)
        @lock.synchronize do
          request_path = ::Middleman::Util.normalize_path(request_path)
          ensure_resource_list_updated!
          @_lookup_by_path[request_path]
        end
      end

      # Find a resource given its destination path
      # @param [String] request_path The destination (output) path of a resource.
      # @return [Middleman::Sitemap::Resource]
      def find_resource_by_destination_path(request_path)
        @lock.synchronize do
          request_path = ::Middleman::Util.normalize_path(request_path)
          ensure_resource_list_updated!
          @_lookup_by_destination_path[request_path]
        end
      end

      # Get the array of all resources
      # @param [Boolean] include_ignored Whether to include ignored resources
      # @return [Array<Middleman::Sitemap::Resource>]
      def resources(include_ignored=false)
        @lock.synchronize do
          ensure_resource_list_updated!
          if include_ignored
            @resources
          else
            @resources_not_ignored ||= @resources.reject(&:ignored?)
          end
        end
      end

      # Invalidate our cached view of resource that are not ingnored. If your extension
      # adds ways to ignore files, you should call this to make sure #resources works right.
      def invalidate_resources_not_ignored_cache!
        @resources_not_ignored = nil
      end

      # Register a handler to provide metadata on a file path
      # @param [Regexp] matcher
      # @return [Array<Array<Proc, Regexp>>]
      def provides_metadata(matcher=nil, &block)
        @_provides_metadata ||= []
        @_provides_metadata << [block, matcher] if block_given?
        @_provides_metadata
      end

      # Get the metadata for a specific file
      # @param [String] source_file
      # @return [Hash]
      def metadata_for_file(source_file)
        blank_metadata = { options: {}, locals: {}, page: {}, blocks: [] }

        provides_metadata.reduce(blank_metadata) do |result, (callback, matcher)|
          next result if matcher && !source_file.match(matcher)

          metadata = callback.call(source_file).dup

          if metadata.key?(:blocks)
            result[:blocks] << metadata[:blocks]
            metadata.delete(:blocks)
          end

          result.deep_merge(metadata)
        end
      end

      # Register a handler to provide metadata on a url path
      # @param [Regexp] matcher
      # @return [Array<Array<Proc, Regexp>>]
      def provides_metadata_for_path(matcher=nil, &block)
        @_provides_metadata_for_path ||= []
        if block_given?
          @_provides_metadata_for_path << [block, matcher]
          @_cached_metadata = {}
        end
        @_provides_metadata_for_path
      end

      # Get the metadata for a specific URL
      # @param [String] request_path
      # @return [Hash]
      def metadata_for_path(request_path)
        return @_cached_metadata[request_path] if @_cached_metadata[request_path]

        blank_metadata = { options: {}, locals: {}, page: {}, blocks: [] }

        @_cached_metadata[request_path] = provides_metadata_for_path.reduce(blank_metadata) do |result, (callback, matcher)|
          case matcher
          when Regexp
            next result unless request_path =~ matcher
          when String
            next result unless File.fnmatch('/' + Util.strip_leading_slash(matcher), "/#{request_path}")
          end

          metadata = callback.call(request_path).dup

          result[:blocks] += Array(metadata.delete(:blocks))

          result.deep_merge(metadata)
        end
      end

      # Get the URL path for an on-disk file
      # @param [String] file
      # @return [String]
      def file_to_path(file)
        file = File.expand_path(file, @app.root)

        prefix = @app.source_dir.sub(/\/$/, '') + '/'
        return false unless file.start_with?(prefix)

        path = file.sub(prefix, '')

        # Replace a file name containing automatic_directory_matcher with a folder
        unless @app.config[:automatic_directory_matcher].nil?
          path = path.gsub(@app.config[:automatic_directory_matcher], '/')
        end

        extensionless_path(path)
      end

      # Get a path without templating extensions
      # @param [String] file
      # @return [String]
      def extensionless_path(file)
        path = file.dup
        path = remove_templating_extensions(path)

        # If there is no extension, look for one
        path = find_extension(path, file) if File.extname(strip_away_locale(path)).empty?
        path
      end

      # Actually update the resource list, assuming anything has called
      # rebuild_resource_list! since the last time it was run. This is
      # very expensive!
      def ensure_resource_list_updated!
        @lock.synchronize do
          return unless @needs_sitemap_rebuild
          @needs_sitemap_rebuild = false

          @app.logger.debug '== Rebuilding resource list'

          @resources = @resource_list_manipulators.reduce([]) do |result, (_, inst)|
            newres = inst.manipulate_resource_list(result)

            # Reset lookup cache
            reset_lookup_cache!
            newres.each do |resource|
              @_lookup_by_path[resource.path] = resource
              @_lookup_by_destination_path[resource.destination_path] = resource
            end

            newres
          end

          invalidate_resources_not_ignored_cache!
        end
      end

      private

      def reset_lookup_cache!
        @lock.synchronize do
          @_lookup_by_path = {}
          @_lookup_by_destination_path = {}
        end
      end

      # Removes the templating extensions, while keeping the others
      # @param [String] path
      # @return [String]
      def remove_templating_extensions(path)
        # Strip templating extensions as long as Tilt knows them
        path = path.sub(File.extname(path), '') while ::Tilt[path]
        path
      end

      # Remove the locale token from the end of the path
      # @param [String] path
      # @return [String]
      def strip_away_locale(path)
        if @app.respond_to? :langs
          path_bits = path.split('.')
          lang = path_bits.last
          return path_bits[0..-2].join('.') if @app.langs.include?(lang.to_sym)
        end

        path
      end

      # Finds an extension for path according to file's extension
      # @param [String] path without extension
      # @param [String] file path with original extensions
      def find_extension(path, file)
        input_ext = File.extname(file)

        unless input_ext.empty?
          input_ext = input_ext.split('.').last.to_sym
          if @app.template_extensions.key?(input_ext)
            path << ".#{@app.template_extensions[input_ext]}"
          end
        end

        path
      end
    end
  end
end
