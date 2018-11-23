require 'set'
require 'middleman-core/core_extensions/data/proxies/base'

module Middleman
  module CoreExtensions
    module Data
      module Proxies
        class ArrayProxy < BaseProxy
          FULL_ACCESS_METHODS = Set.new %i[size any? inspect join]
          WRAPPED_LIST_METHODS = Set.new %i[each select sort shuffle reverse]

          def method_missing(name, *args, &block)
            if self.class.const_get(:WRAPPED_LIST_METHODS).include?(name)
              log_access(:__full_access__)
              return wrapped_array.send(name, *args, &block)
            end

            super
          end

          def fetch(index, default = (_missing_default = true), &block)
            wrap_data index, @data.fetch(index, default, &block)
          end

          def slice(arg, length = (missing_length = true))
            if missing_length
              if arg.is_a?(Range)
                log_access(:__full_access__)
                @data.slice(arg, length)
              else
                relative_index = (@data.size + arg) % @data.size
                wrap_data(relative_index, @data[relative_index])
              end
            else
              log_access(:__full_access__)
              @data.slice(arg, length)
            end
          end
          alias [] slice

          def first
            self[0]
          end

          def last
            self[-1]
          end

          private

          def wrapped_array
            @wrapped_array ||= begin
              i = 0
              @data.map do |d|
                wrap_data(i, d).tap { i += 1 }
              end
            end
          end
        end
      end
    end
  end
end
