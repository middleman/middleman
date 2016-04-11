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
      DATA_FILE_MATCHER = /^(.*?)[\w-]+\.(yml|yaml|json)$/

      def initialize(app, config={}, &block)
        super

        @data_store = DataStore.new(app, DATA_FILE_MATCHER)

        start_watching(app.config[:data_dir])
      end

      def start_watching(dir)
        @original_data_dir = dir

        # Tell the file watcher to observe the :data_dir
        @watcher = app.files.watch :data,
                                   path: File.join(app.root, dir),
                                   only: DATA_FILE_MATCHER

        # Setup data files before anything else so they are available when
        # parsing config.rb
        app.files.on_change(:data, &@data_store.method(:update_files))
      end

      def after_configuration
        return unless @original_data_dir != app.config[:data_dir]

        @watcher.update_path(app.config[:data_dir])
      end

      # The core logic behind the data extension.
      class DataStore
        include Contracts

        # Setup data store
        #
        # @param [Middleman::Application] app The current instance of Middleman
        def initialize(app, data_file_matcher)
          @app = app
          @data_file_matcher = data_file_matcher
          @local_data = {}
          @local_data_enhanced = nil
          @local_sources = {}
          @callback_sources = {}
        end

        # Store static data hash
        #
        # @param [Symbol] name Name of the data, used for namespacing
        # @param [Hash] content The content for this data
        # @return [Hash]
        Contract Symbol, Or[Hash, Array] => Hash
        def store(name=nil, content=nil)
          @local_sources[name.to_s] = content unless name.nil? || content.nil?
          @local_sources
        end

        # Store callback-based data
        #
        # @param [Symbol] name Name of the data, used for namespacing
        # @param [Proc] proc The callback which will return data
        # @return [Hash]
        Contract Maybe[Symbol], Maybe[Proc] => Hash
        def callbacks(name=nil, proc=nil)
          @callback_sources[name.to_s] = proc unless name.nil? || proc.nil?
          @callback_sources
        end

        Contract ArrayOf[IsA['Middleman::SourceFile']], ArrayOf[IsA['Middleman::SourceFile']] => Any
        def update_files(updated_files, removed_files)
          updated_files.each(&method(:touch_file))
          removed_files.each(&method(:remove_file))

          @app.sitemap.rebuild_resource_list!(:touched_data_file)
        end

        # Update the internal cache for a given file path
        #
        # @param [String] file The file to be re-parsed
        # @return [void]
        Contract IsA['Middleman::SourceFile'] => Any
        def touch_file(file)
          data_path = file[:relative_path]
          extension = File.extname(data_path)
          basename  = File.basename(data_path, extension)

          return unless %w(.yaml .yml .json).include?(extension)

          if %w(.yaml .yml).include?(extension)
            data, postscript = ::Middleman::Util::Data.parse(file, @app.config[:frontmatter_delims], :yaml)
            data[:postscript] = postscript if !postscript.nil? && data.is_a?(Hash)
          elsif extension == '.json'
            data, _postscript = ::Middleman::Util::Data.parse(file, @app.config[:frontmatter_delims], :json)
          end

          data_branch = @local_data

          path = data_path.to_s.split(File::SEPARATOR)[0..-2]
          path.each do |dir|
            data_branch[dir] ||= {}
            data_branch = data_branch[dir]
          end

          data_branch[basename] = data

          @local_data_enhanced = nil
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
            data_branch = data_branch[dir]
          end

          data_branch.delete(basename) if data_branch.key?(basename)

          @local_data_enhanced = nil
        end

        # Get a hash from either internal static data or a callback
        #
        # @param [String, Symbol] path The name of the data namespace
        # @return [Hash, nil]
        Contract Or[String, Symbol] => Maybe[Or[Array, IsA['Middleman::Util::EnhancedHash']]]
        def data_for_path(path)
          response = if store.key?(path.to_s)
            store[path.to_s]
          elsif callbacks.key?(path.to_s)
            callbacks[path.to_s].call
          end

          ::Middleman::Util.recursively_enhance(response)
        end

        # "Magically" find namespaces of data if they exist
        #
        # @param [String] path The namespace to search for
        # @return [Hash, nil]
        def method_missing(path)
          if @local_data.key?(path.to_s)
            # Any way to cache this?
            @local_data_enhanced ||= ::Middleman::Util.recursively_enhance(@local_data)
            return @local_data_enhanced[path.to_s]
          else
            result = data_for_path(path)
            return result if result
          end

          super
        end

        # Needed so that method_missing makes sense
        def respond_to?(method, include_private=false)
          super || key?(method)
        end

        # Make DataStore act like a hash. Return requested data, or
        # nil if data does not exist
        #
        # @param [String, Symbol] key The name of the data namespace
        # @return [Hash, nil]
        def [](key)
          __send__(key) if key?(key)
        end

        def key?(key)
          (@local_data.keys + @local_sources.keys + @callback_sources.keys).include?(key.to_s)
        end

        alias has_key? key?

        # Convert all the data into a static hash
        #
        # @return [Hash]
        Contract Hash
        def to_h
          data = {}

          store.each_key do |k|
            data[k] = data_for_path(k)
          end

          callbacks.each_key do |k|
            data[k] = data_for_path(k)
          end

          (@local_data || {}).each do |k, v|
            data[k] = v
          end

          data
        end
      end
    end
  end
end
