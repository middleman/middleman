# Used for merging results of metadata callbacks
require 'active_support/core_ext/hash/deep_merge'
require 'monitor'
require 'hamster'
require 'set'
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
    ManipulatorDescriptor = Struct.new :name, :manipulator, :priority

    class ResourceListContainer
      extend Forwardable
      include Contracts

      def_delegators :@_set, :each, :find, :select, :reject

      Contract IsA['Middleman::Sitemap::Store'], Maybe[ArrayOf[IsA['Middleman::Sitemap::Resource']]] => Any
      def initialize(_store, initial = [])
        @_set = Set.new
        @_store = Store

        reset!(initial)
      end

      Contract Maybe[ArrayOf[IsA['Middleman::Sitemap::Resource']]] => Any
      def reset!(initial = [])
        @_set = Set.new

        @_lookup_by_path = {}
        @_lookup_by_destination_path = {}
        @_lookup_by_binary = Set.new
        @_lookup_by_non_binary = Set.new
        @_lookup_by_source_extension = {}
        @_lookup_by_destination_extension = {}
        @_lookup_by_page_id = {}

        add!(*initial)
      end

      Contract Args[IsA['Middleman::Sitemap::Resource']] => Any
      def add!(*resources)
        resources.each(&method(:add_one!))
      end

      Contract IsA['Middleman::Sitemap::Resource'] => Any
      def add_one!(resource)
        @_set.add resource
        add_cache resource
      end

      Contract Symbol, Maybe[Symbol] => Bool
      def should_run?(key, only = nil)
        return true if only.nil?

        key == only
      end

      Contract IsA['Middleman::Sitemap::Resource'], Maybe[Symbol] => Any
      def add_cache(resource, only = nil)
        if should_run? :path, only
          @_lookup_by_path[::Middleman::Util.normalize_path(resource.path)] = resource
        end

        if should_run? :destination_path, only
          @_lookup_by_destination_path[::Middleman::Util.normalize_path(resource.destination_path)] = resource
        end

        if should_run? :binary, only
          if resource.binary?
            @_lookup_by_binary << resource
          else
            @_lookup_by_non_binary << resource
          end
        end

        if should_run? :source_extension, only
          source_ext = resource.file_descriptor && resource.file_descriptor[:full_path] && ::File.extname(resource.file_descriptor[:full_path])
          if source_ext
            @_lookup_by_source_extension[source_ext] ||= Set.new
            @_lookup_by_source_extension[source_ext] << resource
          end
        end

        if should_run? :destination_extension, only
          @_lookup_by_destination_extension[::File.extname(resource.destination_path)] ||= Set.new
          @_lookup_by_destination_extension[::File.extname(resource.destination_path)] << resource
        end

        if should_run? :page_id, only
          @_lookup_by_page_id[resource.page_id.to_s.to_sym] = resource
        end
      end

      Contract IsA['Middleman::Sitemap::Resource'] => Any
      def remove!(resource)
        @_set.delete resource
        remove_cache resource
      end

      Contract IsA['Middleman::Sitemap::Resource'], Maybe[Symbol] => Any
      def remove_cache(resource, only = nil)
        if should_run? :path, only
          @_lookup_by_path.delete ::Middleman::Util.normalize_path(resource.path)
        end

        if should_run? :destination_path, only
          @_lookup_by_destination_path.delete ::Middleman::Util.normalize_path(resource.destination_path)
        end

        if should_run? :binary, only
          if resource.binary?
            @_lookup_by_binary.delete resource
          else
            @_lookup_by_non_binary.delete resource
          end
        end

        if should_run? :source_extension, only
          source_ext = resource.file_descriptor && resource.file_descriptor[:full_path] && ::File.extname(resource.file_descriptor[:full_path])
          @_lookup_by_source_extension[source_ext].delete resource if source_ext
        end

        if should_run? :destination_extension, only
          if @_lookup_by_destination_extension.key?(::File.extname(resource.destination_path))
            @_lookup_by_destination_extension[::File.extname(resource.destination_path)].delete resource
          end
        end

        if should_run? :page_id, only
          @_lookup_by_page_id.delete resource.page_id.to_s.to_sym
        end
      end

      Contract IsA['Middleman::Sitemap::Resource'], Proc => Any
      def update!(resource, only = nil)
        remove_cache(resource, only)
        yield
        add_cache(resource, only)
      end

      # Find resources given its source extension
      # @param [String] extension The source extension of a resource.
      # @return [Middleman::Sitemap::Resource]
      Contract String => SetOf[IsA['Middleman::Sitemap::Resource']]
      def by_source_extension(extension)
        @_lookup_by_source_extension[extension] || Set.new
      end

      # Find resources given a set of source extensions
      # @param [Set<String>] extensions The source extensions of a resource.
      # @return [Middleman::Sitemap::Resource]
      Contract Or[ArrayOf[String], SetOf[String]] => SetOf[IsA['Middleman::Sitemap::Resource']]
      def by_source_extensions(extensions)
        extensions.reduce(Set.new) do |sum, ext|
          sum | by_source_extension(ext)
        end
      end

      # Find resources given its destination extension
      # @param [String] extension The destination (output) extension of a resource.
      # @return [Middleman::Sitemap::Resource]
      Contract String => SetOf[IsA['Middleman::Sitemap::Resource']]
      def by_extension(extension)
        @_lookup_by_destination_extension[extension] || Set.new
      end

      # Find resources given a set of destination extensions
      # @param [Set<String>] extensions The destination (output) extensions of a resource.
      # @return [Middleman::Sitemap::Resource]
      Contract Or[ArrayOf[String], SetOf[String]] => SetOf[IsA['Middleman::Sitemap::Resource']]
      def by_extensions(extensions)
        extensions.reduce(Set.new) do |sum, ext|
          sum | by_extension(ext)
        end
      end

      # Find a resource given its original path
      # @param [String] request_path The original path of a resource.
      # @return [Middleman::Sitemap::Resource]
      Contract String => Maybe[IsA['Middleman::Sitemap::Resource']]
      def by_path(request_path)
        request_path = ::Middleman::Util.normalize_path(request_path)
        @_lookup_by_path[request_path]
      end

      # Find a resource given its destination path
      # @param [String] request_path The destination (output) path of a resource.
      # @return [Middleman::Sitemap::Resource]
      Contract String => Maybe[IsA['Middleman::Sitemap::Resource']]
      def by_destination_path(request_path)
        request_path = ::Middleman::Util.normalize_path(request_path)
        @_lookup_by_destination_path[request_path]
      end

      # Find a resource given its page id
      # @param [String] page_id The page id.
      # @return [Middleman::Sitemap::Resource]
      Contract Or[String, Symbol] => Maybe[IsA['Middleman::Sitemap::Resource']]
      def by_page_id(page_id)
        @_lookup_by_page_id[page_id.to_s.to_sym]
      end

      # Find a resource given its page id
      # @param [String] page_id The page id.
      # @return [Middleman::Sitemap::Resource]
      Contract Bool => SetOf[IsA['Middleman::Sitemap::Resource']]
      def by_binary(is_binary)
        if is_binary
          @_lookup_by_binary
        else
          @_lookup_by_non_binary
        end
      end

      Contract ArrayOf[IsA['Middleman::Sitemap::Resource']]
      def to_a
        @_set.to_a
      end

      Contract ArrayOf[IsA['Middleman::Sitemap::Resource']] => IsA['Middleman::Sitemap::ResourceListContainer']
      def self.from_a(a)
        new(a)
      end
    end

    # The Store class
    #
    # The Store manages a collection of Resource objects, which represent
    # individual items in the sitemap. Resources are indexed by "source path",
    # which is the path relative to the source directory, minus any template
    # extensions. All "path" parameters used in this class are source paths.
    class Store
      extend Forwardable
      include Contracts

      def_delegator :@resource_list_container, :by_path, :find_resource_by_path
      def_delegator :@resource_list_container, :by_destination_path, :find_resource_by_destination_path
      def_delegator :@resource_list_container, :by_by_binary, :find_resource_by_by_binary
      def_delegator :@resource_list_container, :by_page_id, :find_resource_by_page_id
      def_delegator :@resource_list_container, :by_extension, :find_resource_by_extension
      def_delegator :@resource_list_container, :by_extensions, :find_resource_by_extensions
      def_delegator :@resource_list_container, :by_source_extension, :find_resource_by_source_extension
      def_delegator :@resource_list_container, :by_source_extensions, :find_resource_by_source_extensions

      Contract IsA['Middleman::Application']
      attr_reader :app

      Contract Num
      attr_reader :update_count

      Contract IsA['Middleman::Sitemap::ResourceListContainer']
      attr_reader :resource_list_container

      # Initialize with parent app
      # @param [Middleman::Application] app
      Contract IsA['Middleman::Application'] => Any
      def initialize(app)
        @app = app
        @resource_list_container = ResourceListContainer.new self
        @rebuild_reasons = [:first_run]
        @update_count = 0

        @resource_list_manipulators = ::Hamster::Vector.empty
        @needs_sitemap_rebuild = true

        @lock = Monitor.new

        @app.config_context.class.send :def_delegator, :app, :sitemap
      end

      Contract Symbol, Or[RespondTo[:manipulate_resource_list], RespondTo[:manipulate_resource_list_container!]], Maybe[Or[Num, ArrayOf[Num]]] => Any
      def register_resource_list_manipulators(name, manipulator, priority = 50)
        Array(priority || 50).each do |p|
          register_resource_list_manipulator(name, manipulator, p)
        end
      end

      # Register an object which can transform the sitemap resource list. Best to register
      # these in a `before_configuration` or `after_configuration` hook.
      #
      # @param [Symbol] name Name of the manipulator for debugging
      # @param [#manipulate_resource_list] manipulator Resource list manipulator
      # @param [Numeric] priority Sets the order of this resource list manipulator relative to the rest. By default this is 50, and manipulators run in the order they are registered, but if a priority is provided then this will run ahead of or behind other manipulators.
      # @return [void]
      Contract Symbol, Or[RespondTo[:manipulate_resource_list], RespondTo[:manipulate_resource_list_container!]], Maybe[Num, Bool] => Any
      def register_resource_list_manipulator(name, manipulator, priority = 50)
        # The third argument used to be a boolean - handle those who still pass one
        priority = 50 unless priority.is_a? Numeric
        @resource_list_manipulators = @resource_list_manipulators.push(
          ManipulatorDescriptor.new(name, manipulator, priority)
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

      # Rebuild the list of resources from scratch, using registered manipulators
      # @return [void]
      Contract Symbol => Any
      def rebuild_resource_list!(name)
        @lock.synchronize do
          @rebuild_reasons << name
          @app.logger.debug "== Requesting resource list rebuilding: #{name}"
          @needs_sitemap_rebuild = true
        end
      end

      # Get the array of all resources
      # @param [Boolean] include_ignored Whether to include ignored resources
      # @return [Array<Middleman::Sitemap::Resource>]
      Contract Bool => ResourceList
      def resources(include_ignored = false)
        @lock.synchronize do
          ensure_resource_list_updated!

          if include_ignored
            @resource_list_container.to_a
          else
            @resource_list_container.to_a.reject(&:ignored?)
          end
        end
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

            @resource_list_container.reset!

            @resource_list_manipulators.each do |m|
              ::Middleman::Util.instrument 'sitemap.manipulator', name: m[:name] do
                @app.logger.debug "== Running manipulator: #{m[:name]} (#{m[:priority]})"

                if m[:manipulator].respond_to?(:manipulate_resource_list_container!)
                  m[:manipulator].send(:manipulate_resource_list_container!, @resource_list_container)
                elsif m[:manipulator].respond_to?(:manipulate_resource_list)
                  m[:manipulator].send(:manipulate_resource_list, @resource_list_container.to_a).tap do |result|
                    @resource_list_container.reset!(result)
                  end
                end
              end
            end

            @update_count += 1

            @rebuild_reasons = []
          end
        end
      end

      private

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
