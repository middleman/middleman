require 'set'
require 'middleman-core/core_extensions/data/proxies/base'

module Middleman
  module CoreExtensions
    module Data
      module Proxies
        class ArrayProxy < BaseProxy
          WRAPPED_LIST_METHODS = Set.new %i[each each_with_index select sort shuffle reverse rotate sample]

          def respond_to_missing?(name, *)
            self.class.const_get(:WRAPPED_LIST_METHODS).include?(name) || super
          end

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
                @data.slice(arg)
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

          def first(length = (missing_length = true))
            if missing_length || length == 1
              slice(0)
            else
              slice(0, length)
            end
          end

          def last(length = (missing_length = true))
            if missing_length || length == 1
              slice(-1)
            else
              slice(size - length, length)
            end
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
