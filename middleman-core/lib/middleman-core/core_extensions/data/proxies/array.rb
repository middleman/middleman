require 'middleman-core/core_extensions/data/proxies/base'

module Middleman
  module CoreExtensions
    module Data
      module Proxies
        class ArrayProxy < BaseProxy
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
        end
      end
    end
  end
end
