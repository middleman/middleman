require 'hamster'
require 'middleman-core/dependencies/vertices/vertex'
require 'middleman-core/contracts'

module Middleman
  module CoreExtensions
    module Data
      module Stores
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

          Contract ImmutableSetOf[::Middleman::Dependencies::Vertex]
          def vertices
            Hamster::Set.empty
          end

          Contract Hash
          def to_h
            keys.each_with_object({}) do |k, sum|
              sum[k] = self[k]
            end
          end
        end
      end
    end
  end
end
