require "yui/compressor"

module Middleman
  module Minified
    module Javascript
      include ::Haml::Filters::Base
      def render_with_options(text, options)
        compressor = ::YUI::JavaScriptCompressor.new(:munge => true)
        data = compressor.compress(text)
        <<END
<script type=#{options[:attr_wrapper]}text/javascript#{options[:attr_wrapper]}>#{data.chomp}</script>
END
      end
    end
  
    module StaticJavascript
      def render_path(path)
        if template_exists?(path, :js)
          compressor = YUI::JavaScriptCompressor.new(:munge => true)
          compressor.compress(super)
        else
          super
        end
      end
    end
  end
  
  class Base
    include Middleman::Minified::StaticJavascript
  end
end