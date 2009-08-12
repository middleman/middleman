require 'sinatra/base'
require 'markaby'

module Sinatra
  module Markaby
    # Generate html file using Markaby.
    # Takes the name of a template to render as a Symbol and returns a String with the rendered output.
    #
    # Options for markaby may be specified in Sinatra using set :markaby, { ... }
    # TODO: the options aren't actually used yet
    def mab(template=nil, options={}, locals = {}, &block)
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

  helpers Markaby
end
