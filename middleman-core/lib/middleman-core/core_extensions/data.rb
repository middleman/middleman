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
          require "yaml"
          require "active_support/json"

          app.set :data_dir, "data"
          app.send :include, InstanceMethods
        end
        alias :included :registered
      end

      # Instance methods
      module InstanceMethods
        # Setup data files before anything else so they are available when
        # parsing config.rb
        def initialize
          self.files.changed DataStore.matcher do |file|
            self.data.touch_file(file) if file.start_with?("#{self.data_dir}/")
          end

          self.files.deleted DataStore.matcher do |file|
            self.data.remove_file(file) if file.start_with?("#{self.data_dir}/")
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
        # @return [void]
        def store(name=nil, content=nil)
          @_local_sources ||= {}
          @_local_sources[name.to_s] = content unless name.nil? || content.nil?
          @_local_sources
        end

        # Store callback-based data
        #
        # @param [Symbol] name Name of the data, used for namespacing
        # @param [Proc] proc The callback which will return data
        # @return [void]
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
          file = File.expand_path(file, @app.root)
          extension = File.extname(file)
          basename  = File.basename(file, extension)

          if %w(.yaml .yml).include?(extension)
            data = YAML.load_file(file)
          elsif extension == ".json"
            data = ActiveSupport::JSON.decode(File.read(file))
          else
            return
          end

          @local_data[basename] = ::Middleman::Util.recursively_enhance(data)
        end

        # Remove a given file from the internal cache
        #
        # @param [String] file The file to be cleared
        # @return [void]
        def remove_file(file)
          extension = File.extname(file)
          basename  = File.basename(file, extension)
          @local_data.delete(basename) if @local_data.has_key?(basename)
        end

        # Get a hash hash from either internal static data or a callback
        #
        # @param [String, Symbol] path The name of the data namespace
        # @return [Hash, nil]
        def data_for_path(path)
          response = nil

          @@local_sources ||= {}
          @@callback_sources ||= {}

          if self.store.has_key?(path.to_s)
            response = self.store[path.to_s]
          elsif self.callbacks.has_key?(path.to_s)
            response = self.callbacks[path.to_s].call()
          end

          response
        end

        # "Magically" find namespaces of data if they exist
        #
        # @param [String] path The namespace to search for
        # @return [Hash, nil]
        def method_missing(path)
          if @local_data.has_key?(path.to_s)
            return @local_data[path.to_s]
          else
            result = data_for_path(path)

            if result
              return ::Middleman::Util.recursively_enhance(result)
            end
          end

          super
        end

        # Convert all the data into a static hash
        #
        # @return [Hash]
        def to_h
          data = {}

          self.store.each do |k, v|
            data[k] = data_for_path(k)
          end

          self.callbacks.each do |k, v|
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
