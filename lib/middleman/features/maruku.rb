begin
  require 'maruku'
rescue LoadError
  puts "Maruku not available. Install it with: gem install maruku"
end

module Middleman
  module Maruku
    def self.included(base)
      base.supported_formats << "maruku"
      base.set :maruku, {}
    end
    
    def render_path(path)
      if template_exists?(path, :maruku)
        render :maruku, path.to_sym
      else
        super
      end
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
  
  class Base
    include Middleman::Maruku
  end
end