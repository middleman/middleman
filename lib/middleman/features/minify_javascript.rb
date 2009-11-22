module Middleman
  module Minified
    module Javascript
      include ::Haml::Filters::Base
      def render_with_options(text, options)
        if Middleman::Base.respond_to?(:minify_javascript?) && Middleman::Base.minify_javascript?
          compressor = ::YUI::JavaScriptCompressor.new(:munge => true)
          data = compressor.compress(text)
          %Q{<script type=#{options[:attr_wrapper]}text/javascript#{options[:attr_wrapper]}>#{data.chomp}</script>}
        else
          <<END
<script type=#{options[:attr_wrapper]}text/javascript#{options[:attr_wrapper]}>
  //<![CDATA[
    #{text.rstrip.gsub("\n", "\n    ")}
  //]]>
</script>
END
        end
      end
    end
  end
end