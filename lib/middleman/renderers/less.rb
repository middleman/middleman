require "less"

module Middleman
  module Renderers
    module Less
      def self.included(base)
        base.supported_formats << "less"
      end
    
      def render_path(path, layout)
        if template_exists?(path, :less)
          less(path.to_sym)
        else
          super
        end
      end
    end
  end
end

class Middleman::Base
  include Middleman::Renderers::Less
end
