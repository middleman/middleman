require 'middleman-core/contracts'
require 'middleman-core/core_extensions/data/stores/base'
require 'middleman-core/dependencies/vertices/vertex'
require 'middleman-core/dependencies/vertices/data_collection_vertex'

module Middleman
  module CoreExtensions
    module Data
      module Stores
        # Static data, passed in via config.rb
        class StaticDataStore < BaseDataStore
          extend Forwardable
          include Contracts

          def_delegators :@sources, :key?, :keys, :[]

          Contract Any
          def initialize
            super()

            @sources = {}
            @keys_to_vertex = {}
          end

          Contract Symbol => ImmutableSetOf[::Middleman::Dependencies::Vertex]
          def vertices_for_key(k)
            @keys_to_vertex[k] || ::Hamster::Set.empty
          end

          # Store static data hash
          #
          # @param [Symbol] name Name of the data, used for namespacing
          # @param [Hash] content The content for this data
          # @return [Hash]
          Contract Symbol, Or[Hash, Array] => Any
          def store(name, content)
            @sources[name] = content

            @keys_to_vertex[name] ||= ::Hamster::Set.empty
            @keys_to_vertex[name] <<= ::Middleman::Dependencies::DataCollectionVertex.from_data(name, content)
          end
        end
      end
    end
  end
end
