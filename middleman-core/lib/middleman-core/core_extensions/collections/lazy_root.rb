require 'middleman-core/core_extensions/collections/lazy_step'

module Middleman
  module CoreExtensions
    module Collections
      class LazyCollectorRoot < BasicObject
        def initialize(parent)
          @data = nil
          @parent = parent
        end

        def realize!(data)
          @data = data
        end

        def value(_ctx=nil)
          @data
        end

        def leaves
          @parent.leaves
        end

        def method_missing(name, *args, &block)
          LazyCollectorStep.new(name, args, block, self)
        end
      end
    end
  end
end
