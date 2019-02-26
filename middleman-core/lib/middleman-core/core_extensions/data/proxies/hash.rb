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

          def method_missing(name, *_args)
            return self[name] if @data.key?(name)

            super
          rescue NoMethodError
            nil
          end

          def to_s
            log_access(:__full_access__)
            @data.to_s
          end

          def to_json(*args)
            log_access(:__full_access__)
            @data.to_h.to_json(*args)
          end
        end
      end
    end
  end
end
