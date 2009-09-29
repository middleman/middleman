begin
  require 'markaby'
rescue LoadError
  puts "Markaby not available. Install it with: gem install markaby"
end

module Middleman
  module Markaby
    def self.included(base)
      base.supported_formats << "mab"
    end
    
    def render_path(path)
      if template_exists?(path, :mab)
        markaby path.to_sym
      else
        super
      end
    end
    
    def markaby(template=nil, options={}, locals = {}, &block)
      options, template = template, nil if template.is_a?(Hash)
      template = lambda { block } if template.nil?
      render :mab, template, options, locals
    end

  protected
    def render_mab(template, data, options, locals, &block)
      filename = options.delete(:filename) || '<MARKABY>'
      line = options.delete(:line) || 1
      mab = ::Markaby::Builder.new(locals)
      if data.respond_to?(:to_str)
        eval(data.to_str, binding, filename, line)
      elsif data.kind_of?(Proc)
        data.call(mab)
      end
    end
  end
  
  class Base
    include Middleman::Markaby
  end
end