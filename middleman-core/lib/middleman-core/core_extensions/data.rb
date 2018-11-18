require 'middleman-core/contracts'
require 'middleman-core/util/data'

module Middleman
  module CoreExtensions
    # The data extension parses YAML and JSON files in the `data/` directory
    # and makes them available to `config.rb`, templates and extensions
    class Data < Extension
      attr_reader :data_store

      define_setting :data_dir, ENV['MM_DATA_DIR'] || 'data', 'The directory data files are stored in'

      # Make the internal `data_store` method available as `app.data`
      expose_to_application data: :data_store

      # Exposes `data` to templates
      expose_to_template data: :data_store

      # The regex which tells Middleman which files are for data
      DATA_FILE_MATCHER = /^(.*?)[\w-]+\.(yml|yaml|json)$/.freeze

      Contract IsA['::Middleman::Application'], Hash => Any
      def initialize(app, options_hash = ::Middleman::EMPTY_HASH, &block)
        super

        @data_store = DataStoreController.new(app)

        start_watching(app.config[:data_dir])
      end

      Contract String => Any
      def start_watching(dir)
        @original_data_dir = dir

        # Tell the file watcher to observe the :data_dir
        @watcher = app.files.watch :data,
                                   path: File.expand_path(dir, app.root),
                                   only: DATA_FILE_MATCHER

        # Setup data files before anything else so they are available when
        # parsing config.rb
        app.files.on_change(:data, &@data_store.method(:update_files))
      end

      Contract Any
      def after_configuration
        return unless @original_data_dir != app.config[:data_dir]

        @watcher.update_path(app.config[:data_dir])
      end

      class BaseDataStore
        include Contracts

        Contract Symbol => Bool
        def key?(_k)
          raise NotImplementedError
        end

        Contract Symbol => Or[Array, Hash]
        def [](_k)
          raise NotImplementedError
        end

        Contract ArrayOf[Symbol]
        def keys
          raise NotImplementedError
        end

        Contract Hash
        def to_h
          keys.each_with_object({}) do |k, sum|
            sum[k] = self[k]
          end
        end
      end

      # JSON and YAML files in the data/ directory
      class LocalFileDataStore < BaseDataStore
        extend Forwardable
        include Contracts

        def_delegators :@local_data, :keys, :key?, :[]

        # Contract IsA['::Middleman::Application'] => Any
        def initialize(app)
          super()

          @app = app
          @local_data = {}
        end

        Contract ArrayOf[IsA['Middleman::SourceFile']], ArrayOf[IsA['Middleman::SourceFile']] => Any
        def update_files(updated_files, removed_files)
          updated_files.each(&method(:touch_file))
          removed_files.each(&method(:remove_file))

          @app.sitemap.rebuild_resource_list!(:touched_data_file)
        end

        YAML_EXTS = Set.new %w[.yaml .yml]
        JSON_EXTS = Set.new %w[.json]
        ALL_EXTS = YAML_EXTS | JSON_EXTS

        # Update the internal cache for a given file path
        #
        # @param [String] file The file to be re-parsed
        # @return [void]
        Contract IsA['Middleman::SourceFile'] => Any
        def touch_file(file)
          data_path = file[:relative_path]
          extension = File.extname(data_path)
          basename  = File.basename(data_path, extension)

          return unless ALL_EXTS.include?(extension)

          if YAML_EXTS.include?(extension)
            data, postscript = ::Middleman::Util::Data.parse(file, @app.config[:frontmatter_delims], :yaml)
            data[:postscript] = postscript if !postscript.nil? && data.is_a?(Hash)
          elsif JSON_EXTS.include?(extension)
            data, _postscript = ::Middleman::Util::Data.parse(file, @app.config[:frontmatter_delims], :json)
          end

          data_branch = @local_data

          path = data_path.to_s.split(File::SEPARATOR)[0..-2]
          path.each do |dir|
            data_branch[dir.to_sym] ||= {}
            data_branch = data_branch[dir.to_sym]
          end

          data_branch[basename.to_sym] = data
        end

        # Remove a given file from the internal cache
        #
        # @param [String] file The file to be cleared
        # @return [void]
        Contract IsA['Middleman::SourceFile'] => Any
        def remove_file(file)
          data_path = file[:relative_path]
          extension = File.extname(data_path)
          basename  = File.basename(data_path, extension)

          data_branch = @local_data

          path = data_path.to_s.split(File::SEPARATOR)[0..-2]
          path.each do |dir|
            data_branch = data_branch[dir.to_sym]
          end

          data_branch.delete(basename.to_sym) if data_branch.key?(basename.to_sym)
        end
      end

      # Arbitrary callbacks, can be used for remote data
      class CallbackDataStore < BaseDataStore
        extend Forwardable
        include Contracts

        def_delegators :@sources, :key?, :keys

        Contract Any
        def initialize
          super()

          @sources = {}
        end

        # Store callback-based data
        Contract Symbol, Proc => Any
        def callbacks(name, callback)
          @sources[name] = callback
        end

        def [](k)
          return unless key?(k)

          @sources[k].call
        end
      end

      # Static data, passed in via config.rb
      class StaticDataStore < BaseDataStore
        extend Forwardable
        include Contracts

        def_delegators :@sources, :key?, :keys, :[]

        Contract Any
        def initialize
          super()

          @sources = {}
        end

        # Store static data hash
        #
        # @param [Symbol] name Name of the data, used for namespacing
        # @param [Hash] content The content for this data
        # @return [Hash]
        Contract Symbol, Or[Hash, Array] => Any
        def store(name, content)
          @sources[name] = content
        end
      end

      # The core logic behind the data extension.
      class DataStoreController
        extend Forwardable

        def_delegator :@local_file_data_store, :update_files
        def_delegator :@static_data_store, :store
        def_delegator :@callback_data_store, :callbacks

        def initialize(app)
          @local_file_data_store = LocalFileDataStore.new(app)
          @static_data_store = StaticDataStore.new
          @callback_data_store = CallbackDataStore.new

          # Sorted in order of access precedence.
          @data_stores = [
            @local_file_data_store,
            @static_data_store,
            @callback_data_store
          ]

          @enhanced_cache = {}
        end

        def key?(k)
          @data_stores.any? { |s| s.key?(k) }
        end
        alias has_key? key?

        def key(k)
          source = @data_stores.find { |s| s.key?(k) }
          source[k] unless source.nil?
        end

        def enhanced_key(k)
          value = key(k)

          if @enhanced_cache.key?(k)
            cached_id, cached_value = @enhanced_cache[k]

            return cached_value if cached_id == value.object_id

            @enhanced_cache.delete(k)
          end

          enhanced = ::Middleman::Util.recursively_enhance(value)

          @enhanced_cache[k] = [value.object_id, enhanced]

          enhanced
        end

        # "Magically" find namespaces of data if they exist
        #
        # @param [String] path The namespace to search for
        # @return [Hash, nil]
        def method_missing(method)
          return enhanced_key(method) if key?(method)

          super
        end

        # Needed so that method_missing makes sense
        def respond_to?(method, include_private = false)
          super || key?(method)
        end

        # Convert all the data into a static hash
        #
        # @return [Hash]
        def to_h
          @data_stores.reduce({}) do |sum, store|
            sum.merge(store.to_h)
          end
        end
      end
    end
  end
end
