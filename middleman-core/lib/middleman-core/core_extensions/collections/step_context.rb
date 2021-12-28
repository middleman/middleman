# frozen_string_literal: true

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

        def initialize(app)
          @app = app
          @descriptors = []
        end

        def method_missing(name, *args, &block)
          internal = :"_internal_#{name}"

          if respond_to?(internal)
            send(internal, *args, &block).tap do |r|
              @descriptors << r if r.respond_to?(:execute_descriptor)
            end
          else
            @app.config_context.send(name, *args, &block)
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          return super if method_name.to_s.start_with?('_internal_')

          respond_to?(:"_internal_#{method_name}") || super
        end
      end
    end
  end
end
