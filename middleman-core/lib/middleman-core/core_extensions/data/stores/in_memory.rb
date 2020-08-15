# frozen_string_literal: true

require 'middleman-core/contracts'
require 'middleman-core/core_extensions/data/stores/base'
require 'middleman-core/dependencies/vertices/vertex'
require 'middleman-core/dependencies/vertices/data_collection_vertex'

module Middleman
  module CoreExtensions
    module Data
      module Stores
        # Static data, passed in via config.rb
        class InMemoryDataStore < BaseDataStore
          extend Forwardable
          include Contracts

          def_delegators :@sources, :key?, :keys, :[]

          Contract Any
          def initialize
            super()

            @sources = {}
            @keys_to_vertex = {}
          end

          Contract ImmutableSetOf[::Middleman::Dependencies::Vertex]
          def vertices
            Hamster::Set.new(@keys_to_vertex.values.flatten(1))
          end

          # Store static data hash
          #
          # @param [Symbol] name Name of the data, used for namespacing
          # @param [Hash] content The content for this data
          # @return [Hash]
          Contract Symbol, Or[Hash, Array] => Any
          def store(name, content)
            @sources[name] = content

            @keys_to_vertex[name] = ::Hamster::Set.empty
            @keys_to_vertex[name] <<= ::Middleman::Dependencies::DataCollectionVertex.from_data(name, content)
          end

          # Store callback-based data
          Contract Symbol, Proc => Any
          def callbacks(name, callback)
            store(name, callback.call)
          end
        end
      end
    end
  end
end
