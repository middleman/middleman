module Middleman
  module Renderers
    module CoffeeScript
      class << self
        def registered(app)
          Tilt.register 'coffee', Tilt::CoffeeTemplate
        end
        alias :included :registered
      end
    end
  end
end

unless defined? Tilt::CoffeeTemplate
  # CoffeeScript info:
  # http://jashkenas.github.com/coffee-script/
  class Tilt::CoffeeTemplate < Tilt::Template
    def initialize_engine
      return if defined? ::CoffeeScript
      require_template_library 'coffee-script'
    end

    def prepare
      @output = nil
    end

    def evaluate(scope, locals, &block)
      @output ||= ::CoffeeScript::compile(data, options)
    end
  end
end