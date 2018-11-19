require 'set'
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

          Contract Symbol => SetOf[IsA['::Middleman::Dependencies::BaseDependency']]
          def dependencies_for_key(_k)
            Set.new
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
