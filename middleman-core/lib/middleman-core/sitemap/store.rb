# Used for merging results of metadata callbacks
require 'monitor'
require 'hamster'
require 'middleman-core/extensions'
require 'middleman-core/sitemap/resource'
require 'middleman-core/sitemap/resource_list_container'

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

module Middleman
  # Sitemap namespace
  module Sitemap
    ManipulatorDescriptor = Struct.new :name, :manipulator, :priority

    # The Store class
    #
    # The Store manages a collection of Resource objects, which represent
    # individual items in the sitemap. Resources are indexed by "source path",
    # which is the path relative to the source directory, minus any template
    # extensions. All "path" parameters used in this class are source paths.
    class Store
      extend Forwardable
      include Contracts

      def_delegators :@resources, :by_extensions, :by_destination_path, :by_path, :by_binary, :by_page_id, :by_extension, :by_source_extension, :by_source_extensions, :with_ignored, :without_ignored

      # Backwards compat to old API from MM v4.
      alias find_resource_by_path by_path
      alias find_resource_by_destination_path by_destination_path

      Contract IsA['Middleman::Application']
      attr_reader :app

      Contract Num
      attr_reader :update_count

      Contract ::Middleman::Sitemap::ResourceListContainer
      attr_reader :resources

      # Initialize with parent app
      # @param [Middleman::Application] app
      Contract IsA['Middleman::Application'] => Any
      def initialize(app)
        @app = app
        @resources = ResourceListContainer.new
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

      # Get the URL path for an on-disk file
      # @param [String] file
      # @return [String]
      Contract Or[Pathname, IsA['Middleman::SourceFile']] => String
      def file_to_path(file)
        relative_path = file.is_a?(Pathname) ? file.to_s : file[:relative_path].to_s

        # Replace a file name containing automatic_directory_matcher with a folder
        relative_path = relative_path.gsub(@app.config[:automatic_directory_matcher], '/') unless @app.config[:automatic_directory_matcher].nil?

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

            @resources.reset!

            @resource_list_manipulators.each do |m|
              ::Middleman::Util.instrument 'sitemap.manipulator', name: m[:name] do
                @app.logger.debug "== Running manipulator: #{m[:name]} (#{m[:priority]})"

                if m[:manipulator].respond_to?(:manipulate_resource_list_container!)
                  m[:manipulator].send(:manipulate_resource_list_container!, @resources)
                elsif m[:manipulator].respond_to?(:manipulate_resource_list)
                  m[:manipulator].send(:manipulate_resource_list, resources.to_a).tap do |result|
                    @resources.reset!(result)
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
