require 'middleman-core/core_extensions/data/proxies/base'

module Middleman
  module CoreExtensions
    module Data
      module Proxies
        class HashProxy < BaseProxy
          FULL_ACCESS_METHODS = Set.new %i[size inspect keys key? values each_key]

          def fetch(key, default = Undefined, &block)
            wrap_data key.to_sym, @data.fetch(key, default, &block)
          end

          def [](key)
            wrap_data key.to_sym, @data[key]
          end
          alias get []

          def method_missing(name, *args, &block)
            if @data.key?(name)
              self[name]
            else
              nil
            end
          end
        end
      end
    end
  end
end
