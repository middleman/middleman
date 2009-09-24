require 'maruku'
require 'sinatra/base'

module Sinatra
  module Maruku
    def maruku(template, options={}, locals={})
      render :maruku, template, options, locals
    end
    
  private
    def render_maruku(template, data, options, locals, &block)
      maruku_src = render_erb(template, data, options, locals, &block)
      instance = ::Maruku.new(maruku_src, options)
      if block_given?
        # render layout
        instance.to_html_document
      else
        # render template
        instance.to_html
      end  
    end
  end
  
  helpers Maruku
end
