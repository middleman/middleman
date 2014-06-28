module Middleman
  module CoreExtensions
    module Collections
      class StepContext
        def self.add_to_context(name, &func)
          send(:define_method, :"_internal_#{name}", &func)
        end

        attr_reader :descriptors

        def initialize
          @descriptors = []
        end

        def method_missing(name, *args, &block)
          internal = :"_internal_#{name}"
          if respond_to?(internal)
            @descriptors << send(internal, *args, &block)
          else
            super
          end
        end
      end
    end
  end
end
