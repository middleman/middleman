require "yui/compressor"
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
  
  class Builder
    alias_method :pre_yui_after_run, :after_run
    def after_run
      pre_yui_after_run
      
      compressor = ::YUI::JavaScriptCompressor.new(:munge => true)
      Dir[File.join(Middleman::Base.build_dir, Middleman::Base.js_dir, "**", "*.js")].each do |path|
        lines = IO.readlines(path)
        if lines.length > 1
          compressed_js = compressor.compress(lines.join($/))
          File.open(path, 'w') { |f| f.write(compressed_js) }
          say "<%= color('#{"[COMPRESSED]".rjust(12)}', :yellow) %>  " + path.gsub(Middleman::Base.build_dir+"/", '')
        end
      end
    end
  end
end

Middleman::Base.supported_formats << "js"