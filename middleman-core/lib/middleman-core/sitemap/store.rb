# Used for merging results of metadata callbacks
require "active_support/core_ext/hash/deep_merge"
require 'monitor'

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

      # Initialize with parent app
      # @param [Middleman::Application] app
      def initialize(app)
        @app   = app
        @resources = []
        @_cached_metadata = {}
        @resource_list_manipulators = []
        @needs_sitemap_rebuild = true
        @lock = Monitor.new

        reset_lookup_cache!

        # Register classes which can manipulate the main site map list
        register_resource_list_manipulator(:on_disk, Middleman::Sitemap::Extensions::OnDisk.new(self))

        # Proxies
        register_resource_list_manipulator(:proxies, @app.proxy_manager)
      end

      # Register a klass which can manipulate the main site map list. Best to register
      # these in a before_configuration or after_configuration hook.
      #
      # @param [Symbol] name Name of the manipulator for debugging
      # @param [Class, Module] inst Abstract namespace which can update the resource list
      # @return [void]
      def register_resource_list_manipulator(name, inst, unused=true)
        @resource_list_manipulators << [name, inst]
        rebuild_resource_list!(:registered_new)
      end

      # Rebuild the list of resources from scratch, using registed manipulators
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
            @resources.reject(&:ignored?)
          end
        end
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
        blank_metadata = { :options => {}, :locals => {}, :page => {}, :blocks => [] }

        provides_metadata.inject(blank_metadata) do |result, (callback, matcher)|
          next result if matcher && !source_file.match(matcher)

          metadata = callback.call(source_file)

          if metadata.has_key?(:blocks)
            result[:blocks] << metadata[:blocks]
            metadata.delete(:blocks)
          end

          result.deep_merge(metadata)
        end
      end

      # Register a handler to provide metadata on a url path
      # @param [Regexp] matcher
      # @param [Symbol] origin an indicator of where this metadata came from - only one
      #                        block per [matcher, origin] pair may exist.
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

        blank_metadata = { :options => {}, :locals => {}, :page => {}, :blocks => [] }

        @_cached_metadata[request_path] = provides_metadata_for_path.inject(blank_metadata) do |result, (callback, matcher)|
          case matcher
          when Regexp
            next result unless request_path =~ matcher
          when String
            next result unless File.fnmatch("/" + Util.strip_leading_slash(matcher), "/#{request_path}")
          end

          metadata = callback.call(request_path)

          result[:blocks] += Array(metadata.delete(:blocks))

          result.deep_merge(metadata)
        end
      end

      # Get the URL path for an on-disk file
      # @param [String] file
      # @return [String]
      def file_to_path(file)
        file = File.expand_path(file, @app.root)

        prefix = @app.source_dir.sub(/\/$/, "") + "/"
        return false unless file.start_with?(prefix)

        path = file.sub(prefix, "")

        # Replace a file name containing automatic_directory_matcher with a folder
        unless @app.automatic_directory_matcher.nil?
          path = path.gsub(@app.automatic_directory_matcher, "/")
        end

        extensionless_path(path)
      end

      # Get a path without templating extensions
      # @param [String] file
      # @return [String]
      def extensionless_path(file)
        path = file.dup

        end_of_the_line = false
        while !end_of_the_line
          if !::Tilt[path].nil?
            path = path.sub(File.extname(path), "")
          else
            end_of_the_line = true
          end
        end

        # If there is no extension, look for one
        if File.extname(path).empty?
          input_ext = File.extname(file)

          if !input_ext.empty?
            input_ext = input_ext.split(".").last.to_sym
            if @app.template_extensions.has_key?(input_ext)
              path << ".#{@app.template_extensions[input_ext]}"
            end
          end
        end

        path
      end

      # Actually update the resource list, assuming anything has called
      # rebuild_resource_list! since the last time it was run. This is
      # very expensive!
      def ensure_resource_list_updated!
        @lock.synchronize do
          return unless @needs_sitemap_rebuild
          @needs_sitemap_rebuild = false

          @app.logger.debug "== Rebuilding resource list"

          @resources = @resource_list_manipulators.inject([]) do |result, (_, inst)|
            newres = inst.manipulate_resource_list(result)

            # Reset lookup cache
            reset_lookup_cache!
            newres.each do |resource|
              @_lookup_by_path[resource.path] = resource
              @_lookup_by_destination_path[resource.destination_path] = resource
            end

            newres
          end
        end
      end

      private

      def reset_lookup_cache!
        @lock.synchronize {
          @_lookup_by_path = {}
          @_lookup_by_destination_path = {}
        }
      end
    end
  end
end
