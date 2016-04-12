module Middleman
  module CoreExtensions
    module Collections
      class StepContext
        class << self
          attr_accessor :current

          def add_to_context(name, &func)
            send(:define_method, :"_internal_#{name}", &func)
          end
        end

        attr_reader :descriptors

        def initialize
          @descriptors = []
        end

        def method_missing(name, *args, &block)
          internal = :"_internal_#{name}"

          return super unless respond_to?(internal)

          send(internal, *args, &block).tap do |r|
            @descriptors << r if r.respond_to?(:execute_descriptor)
          end
        end
      end
    end
  end
end
