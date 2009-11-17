require "middleman/builder"

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
  end
end

Middleman::Base.supported_formats << "js"