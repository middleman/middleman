require 'middleman-core/core_extensions/data/proxies/base'

module Middleman
  module CoreExtensions
    module Data
      module Proxies
        class HashProxy < BaseProxy
          def fetch(key, default = Undefined, &block)
            wrap_data key.to_sym, @data.fetch(key, default, &block)
          end

          def [](key)
            wrap_data key.to_sym, @data[key]
          end
          alias get []

          def respond_to_missing?(name, *)
            @data.key?(name) || super
          end

          def method_missing(name, *_args)
            return self[name] if @data.key?(name)

            super
          rescue NoMethodError
            nil
          end
        end
      end
    end
  end
end
