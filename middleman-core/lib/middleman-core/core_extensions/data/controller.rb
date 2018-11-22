require 'hamster'
require 'middleman-core/util/data'
require 'middleman-core/core_extensions/data/stores/local_file'
require 'middleman-core/core_extensions/data/stores/in_memory'
require 'middleman-core/core_extensions/data/proxies/array'
require 'middleman-core/core_extensions/data/proxies/hash'

module Middleman
  module CoreExtensions
    module Data
      # The core logic behind the data extension.
      class DataStoreController
        extend Forwardable

        def_delegator :@local_file_data_store, :update_files
        def_delegators :@in_memory_data_store, :store, :callbacks

        def initialize(app)
          @local_file_data_store = Data::Stores::LocalFileDataStore.new(app)
          @in_memory_data_store = Data::Stores::InMemoryDataStore.new

          # Sorted in order of access precedence.
          @data_stores = [
            @local_file_data_store,
            @in_memory_data_store
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

        def enhanced_data(k)
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

        def proxied_data(k, parent = nil)
          data = enhanced_data(k)

          if data.is_a? ::Middleman::Util::EnhancedHash
            Data::Proxies::HashProxy.new(k, data, parent)
          elsif data.is_a? ::Array
            Data::Proxies::ArrayProxy.new(k, data, parent)
          else
            raise 'Invalid data to wrap'
          end
        end

        # "Magically" find namespaces of data if they exist
        #
        # @param [String] path The namespace to search for
        # @return [Hash, nil]
        def method_missing(method)
          return proxied_data(method) if key?(method)

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
