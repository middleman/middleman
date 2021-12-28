# frozen_string_literal: true

require 'middleman-core/core_extensions/collections/lazy_step'

module Middleman
  module CoreExtensions
    module Collections
      class LazyCollectorRoot < BasicObject
        DELEGATE = %i[hash eql? is_a? puts p].freeze

        def initialize(parent)
          @data = nil
          @parent = parent
        end

        def realize!(data)
          @data = data
        end

        def value(_ctx = nil)
          @data
        end

        def leaves
          @parent.leaves
        end

        def method_missing(name, *args, &block)
          return ::Kernel.send(name, *args, &block) if DELEGATE.include? name

          LazyCollectorStep.new(name, args, block, self)
        end

        def respond_to_missing?(method_name, include_private = false)
          true
        end
      end
    end
  end
end
