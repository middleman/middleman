# Used for merging results of metadata callbacks
require 'active_support/core_ext/hash/deep_merge'
require 'monitor'
require 'hamster'

require 'middleman-core/extensions'

# Files on Disk
::Middleman::Extensions.register :sitemap_ondisk, auto_activate: :before_configuration do
  require 'middleman-core/sitemap/extensions/on_disk'
  ::Middleman::Sitemap::Extensions::OnDisk
end

# Files on Disk (outside the project root)
::Middleman::Extensions.register :sitemap_import, auto_activate: :before_configuration do
  require 'middleman-core/sitemap/extensions/import'
  ::Middleman::Sitemap::Extensions::Import
end

# Endpoints
::Middleman::Extensions.register :sitemap_endpoint, auto_activate: :before_configuration do
  require 'middleman-core/sitemap/extensions/request_endpoints'
  ::Middleman::Sitemap::Extensions::RequestEndpoints
end

# Proxies
::Middleman::Extensions.register :sitemap_proxies, auto_activate: :before_configuration do
  require 'middleman-core/sitemap/extensions/proxies'
  ::Middleman::Sitemap::Extensions::Proxies
end

# Redirects
::Middleman::Extensions.register :sitemap_redirects, auto_activate: :before_configuration do
  require 'middleman-core/sitemap/extensions/redirects'
  ::Middleman::Sitemap::Extensions::Redirects
end

# Move Files
::Middleman::Extensions.register :sitemap_move_files, auto_activate: :before_configuration do
  require 'middleman-core/sitemap/extensions/move_file'
  ::Middleman::Sitemap::Extensions::MoveFile
end

# Ignores
::Middleman::Extensions.register :sitemap_ignore, auto_activate: :before_configuration do
  require 'middleman-core/sitemap/extensions/ignores'
  ::Middleman::Sitemap::Extensions::Ignores
end

require 'middleman-core/contracts'

module Middleman
  # Sitemap namespace
  module Sitemap
    ManipulatorDescriptor = Struct.new :name, :manipulator, :priority, :custom_name

    # The Store class
    #
    # The Store manages a collection of Resource objects, which represent
    # individual items in the sitemap. Resources are indexed by "source path",
    # which is the path relative to the source directory, minus any template
    # extensions. All "path" parameters used in this class are source paths.
    class Store
      include Contracts

      Contract IsA['Middleman::Application']
      attr_reader :app

      Contract Num
      attr_reader :update_count

      # Initialize with parent app
      # @param [Middleman::Application] app
      Contract IsA['Middleman::Application'] => Any
      def initialize(app)
        @app = app
        @resources = []
        @rebuild_reasons = [:first_run]
        @update_count = 0

        @resource_list_manipulators = ::Hamster::Vector.empty
        @needs_sitemap_rebuild = true

        @lock = Monitor.new
        reset_lookup_cache!

        @app.config_context.class.send :def_delegator, :app, :sitemap
      end

      Contract Symbol, RespondTo[:manipulate_resource_list], Maybe[Or[Num, ArrayOf[Num]]], Maybe[Symbol] => Any
      def register_resource_list_manipulators(name, manipulator, priority=50, custom_name=nil)
        Array(priority || 50).each do |p|
          register_resource_list_manipulator(name, manipulator, p, custom_name)
        end
      end

      # Register an object which can transform the sitemap resource list. Best to register
      # these in a `before_configuration` or `after_configuration` hook.
      #
      # @param [Symbol] name Name of the manipulator for debugging
      # @param [#manipulate_resource_list] manipulator Resource list manipulator
      # @param [Numeric] priority Sets the order of this resource list manipulator relative to the rest. By default this is 50, and manipulators run in the order they are registered, but if a priority is provided then this will run ahead of or behind other manipulators.
      # @param [Symbol] custom_name The method name to execute.
      # @return [void]
      Contract Symbol, RespondTo[:manipulate_resource_list], Maybe[Num, Bool], Maybe[Symbol] => Any
      def register_resource_list_manipulator(name, manipulator, priority=50, custom_name=nil)
        # The third argument used to be a boolean - handle those who still pass one
        priority = 50 unless priority.is_a? Numeric
        @resource_list_manipulators = @resource_list_manipulators.push(
          ManipulatorDescriptor.new(name, manipulator, priority, custom_name)
        )

        # The index trick is used so that the sort is stable - manipulators with the same priority
        # will always be ordered in the same order as they were registered.
        n = 0
        @resource_list_manipulators = @resource_list_manipulators.sort_by do |m|
          n += 1
          [m[:priority], n]
        end

        rebuild_resource_list!(:"registered_new_manipulator_#{name}")
      end

      # Rebuild the list of resources from scratch, using registed manipulators
      # @return [void]
      Contract Symbol => Any
      def rebuild_resource_list!(name)
        @lock.synchronize do
          @rebuild_reasons << name
          @app.logger.debug "== Requesting resource list rebuilding: #{name}"
          @needs_sitemap_rebuild = true
        end
      end

      # Find a resource given its original path
      # @param [String] request_path The original path of a resource.
      # @return [Middleman::Sitemap::Resource]
      Contract String => Maybe[IsA['Middleman::Sitemap::Resource']]
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
      Contract String => Maybe[IsA['Middleman::Sitemap::Resource']]
      def find_resource_by_destination_path(request_path)
        @lock.synchronize do
          request_path = ::Middleman::Util.normalize_path(request_path)
          ensure_resource_list_updated!
          @_lookup_by_destination_path[request_path]
        end
      end

      # Find a resource given its page id
      # @param [String] page_id The page id.
      # @return [Middleman::Sitemap::Resource]
      Contract Or[String, Symbol] => Maybe[IsA['Middleman::Sitemap::Resource']]
      def find_resource_by_page_id(page_id)
        @lock.synchronize do
          ensure_resource_list_updated!
          @_lookup_by_page_id[page_id.to_s.to_sym]
        end
      end

      # Get the array of all resources
      # @param [Boolean] include_ignored Whether to include ignored resources
      # @return [Array<Middleman::Sitemap::Resource>]
      Contract Bool => ResourceList
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

      # Invalidate our cached view of resource that are not ignored. If your extension
      # adds ways to ignore files, you should call this to make sure #resources works right.
      def invalidate_resources_not_ignored_cache!
        @resources_not_ignored = nil
      end

      # Get the URL path for an on-disk file
      # @param [String] file
      # @return [String]
      Contract Or[Pathname, IsA['Middleman::SourceFile']] => String
      def file_to_path(file)
        relative_path = file.is_a?(Pathname) ? file.to_s : file[:relative_path].to_s

        # Replace a file name containing automatic_directory_matcher with a folder
        unless @app.config[:automatic_directory_matcher].nil?
          relative_path = relative_path.gsub(@app.config[:automatic_directory_matcher], '/')
        end

        extensionless_path(relative_path)
      end

      # Get a path without templating extensions
      # @param [String] file
      # @return [String]
      Contract String => String
      def extensionless_path(file)
        path = file.dup
        ::Middleman::Util.remove_templating_extensions(path)
      end

      # Actually update the resource list, assuming anything has called
      # rebuild_resource_list! since the last time it was run. This is
      # very expensive!
      def ensure_resource_list_updated!
        return if @app.config[:disable_sitemap]

        @lock.synchronize do
          return unless @needs_sitemap_rebuild

          ::Middleman::Util.instrument 'sitemap.update', reasons: @rebuild_reasons.uniq do
            @needs_sitemap_rebuild = false

            @app.logger.debug '== Rebuilding resource list'

            @resources = []

            @resource_list_manipulators.each do |m|
              ::Middleman::Util.instrument 'sitemap.manipulator', name: m[:name] do
                @app.logger.debug "== Running manipulator: #{m[:name]} (#{m[:priority]})"
                @resources = m[:manipulator].send(m[:custom_name] || :manipulate_resource_list, @resources)

                # Reset lookup cache
                reset_lookup_cache!

                # Rebuild cache
                @resources.each do |resource|
                  @_lookup_by_path[resource.path] = resource
                end

                @resources.each do |resource|
                  @_lookup_by_destination_path[resource.destination_path] = resource
                end

                # NB: This needs to be done after the previous two steps,
                # since some proxy resources are looked up by path in order to
                # get their metadata and subsequently their page_id.
                @resources.each do |resource|
                  @_lookup_by_page_id[resource.page_id.to_s.to_sym] = resource
                end

                invalidate_resources_not_ignored_cache!
              end
            end

            @update_count += 1

            @rebuild_reasons = []
          end
        end
      end

      private

      def reset_lookup_cache!
        @lock.synchronize do
          @_lookup_by_path = {}
          @_lookup_by_destination_path = {}
          @_lookup_by_page_id = {}
        end
      end

      # Remove the locale token from the end of the path
      # @param [String] path
      # @return [String]
      Contract String => String
      def strip_away_locale(path)
        if @app.extensions[:i18n]
          path_bits = path.split('.')
          lang = path_bits.last
          return path_bits[0..-2].join('.') if @app.extensions[:i18n].langs.include?(lang.to_sym)
        end

        path
      end
    end
  end
end
