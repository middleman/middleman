class Middleman::Base
  def coffee(template, options={}, locals={})
    options[:layout] = false
    render :coffee, template, options, locals
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
  Tilt.register 'coffee', Tilt::CoffeeTemplate
end

Middleman::Renderers.register(:coffee, Tilt::CoffeeTemplate)