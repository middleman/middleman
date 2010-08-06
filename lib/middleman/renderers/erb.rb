require "erb"

module Middleman
  module Renderers
    module ERb
      def self.included(base)
        base.supported_formats << "erb"
      end
    
      def render_path(path, layout)
        if template_exists?(path, :erb)
          layout = false if File.extname(path) == ".xml"
          erb(path.to_sym, :layout => layout)
        else
          super
        end
      end
    end
  end
end

class Middleman::Base
  include Middleman::Renderers::ERb
end
