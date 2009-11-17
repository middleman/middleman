module Markaby
  class Template
    def initialize(template)
      @template = template      
    end
    def render(*args)
      output = Builder.new(*args)
      output.instance_eval @template
      return output.to_s
    end
  end
end
