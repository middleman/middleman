module Middleman
  module CoreExtensions
    # The data extension parses YAML and JSON files in the data/ directory
    # and makes them available to config.rb, templates and extensions
    module Data
      # Extension registered
      class << self
        # @private
        def registered(app)
          # Data formats
          require 'yaml'
          require 'active_support/json'

          app.config.define_setting :data_dir, 'data', 'The directory data files are stored in'
          app.send :include, InstanceMethods
        end
        alias_method :included, :registered
      end

      # Instance methods
      module InstanceMethods
        # Setup data files before anything else so they are available when
        # parsing config.rb
        def initialize
          files.changed DataStore.matcher do |file|
            data.touch_file(file) if file.start_with?("#{config[:data_dir]}/")
          end

          files.deleted DataStore.matcher do |file|
            data.remove_file(file) if file.start_with?("#{config[:data_dir]}/")
          end

          super
        end

        # The data object
        #
        # @return [DataStore]
        def data
          @_data ||= DataStore.new(self)
        end
      end

      # The core logic behind the data extension.
      class DataStore
        # Static methods
        class << self
          # The regex which tells Middleman which files are for data
          #
          # @return [Regexp]
          def matcher
            %r{[\w-]+\.(yml|yaml|json)$}
          end
        end

        # Store static data hash
        #
        # @param [Symbol] name Name of the data, used for namespacing
        # @param [Hash] content The content for this data
        # @return [Hash]
        def store(name=nil, content=nil)
          @_local_sources ||= {}
          @_local_sources[name.to_s] = content unless name.nil? || content.nil?
          @_local_sources
        end

        # Store callback-based data
        #
        # @param [Symbol] name Name of the data, used for namespacing
        # @param [Proc] proc The callback which will return data
        # @return [Hash]
        def callbacks(name=nil, proc=nil)
          @_callback_sources ||= {}
          @_callback_sources[name.to_s] = proc unless name.nil? || proc.nil?
          @_callback_sources
        end

        # Setup data store
        #
        # @param [Middleman::Application] app The current instance of Middleman
        def initialize(app)
          @app = app
          @local_data = {}
        end

        # Update the internal cache for a given file path
        #
        # @param [String] file The file to be re-parsed
        # @return [void]
        def touch_file(file)
          root = Pathname(@app.root)
          full_path = root + file
          extension = File.extname(file)
          basename  = File.basename(file, extension)

          data_path = full_path.relative_path_from(root + @app.config[:data_dir])

          if %w(.yaml .yml).include?(extension)
            data = YAML.load_file(full_path)
          elsif extension == '.json'
            data = ActiveSupport::JSON.decode(full_path.read)
          else
            return
          end

          data_branch = @local_data

          path = data_path.to_s.split(File::SEPARATOR)[0..-2]
          path.each do |dir|
            data_branch[dir] ||= ::Middleman::Util.recursively_enhance({})
            data_branch = data_branch[dir]
          end

          data_branch[basename] = ::Middleman::Util.recursively_enhance(data)
        end

        # Remove a given file from the internal cache
        #
        # @param [String] file The file to be cleared
        # @return [void]
        def remove_file(file)
          root = Pathname(@app.root)
          full_path = root + file
          extension = File.extname(file)
          basename  = File.basename(file, extension)

          data_path = full_path.relative_path_from(root + @app.config[:data_dir])

          data_branch = @local_data

          path = data_path.to_s.split(File::SEPARATOR)[0..-2]
          path.each do |dir|
            data_branch = data_branch[dir]
          end

          data_branch.delete(basename) if data_branch.key?(basename)
        end

        # Get a hash from either internal static data or a callback
        #
        # @param [String, Symbol] path The name of the data namespace
        # @return [Hash, nil]
        def data_for_path(path)
          response = nil

          if store.key?(path.to_s)
            response = store[path.to_s]
          elsif callbacks.key?(path.to_s)
            response = callbacks[path.to_s].call
          end

          response
        end

        # "Magically" find namespaces of data if they exist
        #
        # @param [String] path The namespace to search for
        # @return [Hash, nil]
        def method_missing(path)
          if @local_data.key?(path.to_s)
            return @local_data[path.to_s]
          else
            result = data_for_path(path)
            return ::Middleman::Util.recursively_enhance(result) if result
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
          @local_data.key?(key.to_s) || data_for_path(key)
        end

        alias_method :has_key?, :key?

        # Convert all the data into a static hash
        #
        # @return [Hash]
        def to_h
          data = {}

          store.each do |k, _|
            data[k] = data_for_path(k)
          end

          callbacks.each do |k, _|
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
