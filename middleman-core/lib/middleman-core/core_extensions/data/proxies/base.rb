require 'hamster'
require 'middleman-core/util/data'

module Middleman
  module CoreExtensions
    module Data
      module Proxies
        class BaseProxy
          attr_reader :accessed_keys

          def initialize(key, data, parent = nil)
            @key = key
            @data = data
            @parent = parent
            @accessed_keys = ::Hamster::Set.new
          end

          def method_missing(name, *args, &block)
            if @data.respond_to?(name)
              log_access(:__full_access__)

              return @data.send(name, *args, &block)
            end

            super
          end

          def _top
            return @parent._top if @parent.is_a?(BaseProxy)

            self
          end

          def _replace_parent(new_parent)
            @parent = new_parent
          end

          protected

          def log_access(key)
            access_key = [@key, key].flatten
            access_key_vector = ::Hamster::Vector.new(access_key)

            return if @accessed_keys.include?(access_key_vector)

            @accessed_keys <<= access_key_vector

            @parent&.log_access(access_key)
          end

          def wrap_data(key, data)
            if data.is_a? ::Middleman::Util::EnhancedHash
              HashProxy.new(key, data, self)
            elsif data.is_a? ::Array
              ArrayProxy.new(key, data, self)
            else
              log_access(key)
              data
            end
          end
        end
      end
    end
  end
end
