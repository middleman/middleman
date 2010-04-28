require "erb"

module Middleman
  module ERb
    module Renderer
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
  include Middleman::ERb::Renderer
end