require "builder"

module Middleman
  module Renderers
    module Builder
      def self.included(base)
        base.supported_formats << "builder"
      end
    
      def render_path(path, layout)
        if template_exists?(path, :builder)
          builder(path.to_sym, :layout => layout)
        else
          super
        end
      end
    end
  end
end

class Middleman::Base
  include Middleman::Renderers::Builder
end
