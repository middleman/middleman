require 'middleman-core/contracts'
require 'middleman-core/core_extensions/data/stores/base'

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
      end
    end
  end
end
