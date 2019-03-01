require 'hamster'
require 'middleman-core/util/data'

module Middleman
  module CoreExtensions
    module Data
      module Proxies
        class BaseProxy
          attr_reader :accessed_keys
          attr_reader :depth

          def initialize(key, data, data_collection_depth, parent = nil)
            @key = key
            @data = data
            @parent = parent

            @data_collection_depth = data_collection_depth
            @depth = @parent.nil? || !@parent.is_a?(BaseProxy) ? 0 : @parent.depth + 1

            @accessed_keys = ::Hamster::Set.new
          end

          def respond_to_missing?(name, *)
            @data.respond_to?(name) || super
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

          def as_json(*args)
            log_access(:__full_access__)
            @data.as_json(*args)
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
            if @depth >= @data_collection_depth
              log_access(:__full_access__)
              ::Middleman::Util.recursively_enhance(data)
            elsif data.is_a? ::Middleman::Util::EnhancedHash
              HashProxy.new(key, data, @data_collection_depth, self)
            elsif data.is_a? ::Array
              ArrayProxy.new(key, data, @data_collection_depth, self)
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
