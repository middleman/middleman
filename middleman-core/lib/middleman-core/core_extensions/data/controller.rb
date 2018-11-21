require 'hamster'
require 'middleman-core/util/data'
require 'middleman-core/core_extensions/data/stores/local_file'
require 'middleman-core/core_extensions/data/stores/static'
require 'middleman-core/core_extensions/data/stores/callback'

module Middleman
  module CoreExtensions
    module Data
      # The core logic behind the data extension.
      class DataStoreController
        extend Forwardable

        def_delegator :@local_file_data_store, :update_files
        def_delegator :@static_data_store, :store
        def_delegator :@callback_data_store, :callbacks

        def initialize(app)
          @local_file_data_store = Data::Stores::LocalFileDataStore.new(app)
          @static_data_store = Data::Stores::StaticDataStore.new
          @callback_data_store = Data::Stores::CallbackDataStore.new

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

        def vertices
          @data_stores.reduce(::Hamster::Set.empty) do |sum, s|
            sum | s.vertices
          end
        end

        def vertices_for_key(k)
          @data_stores.reduce(::Hamster::Set.empty) do |sum, s|
            sum | s.vertices_for_key(k)
          end
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
