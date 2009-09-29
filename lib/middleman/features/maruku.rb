begin
  require 'maruku'
rescue LoadError
  puts "Maruku not available. Install it with: gem install maruku"
end

module Middleman
  module Maruku
    def render_path(path)
      if template_exists?(path, :maruku)
        maruku path.to_sym
      else
        super
      end
    end
    
    def maruku(template, options={}, locals={})
      render :maruku, template, options, locals
    end

  private
    def render_maruku(data, options, locals, &block)
      maruku_src = render_erb(data, options, locals, &block)
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
  
  class Base
    include Middlman::Maruku
  end
end