require 'middleman-core/contracts'
require 'middleman-core/core_extensions/data/stores/base'

module Middleman
  module CoreExtensions
    module Data
      module Stores
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
      end
    end
  end
end
