class Middleman::Features::MinifyJavascript
  def initialize(app, config)
    Haml::Javascript.send :include, ::Haml::Filters::Base
    
    require "middleman/features/minify_javascript/rack"
    app.use Middleman::Rack::MinifyJavascript
  end
  
  module Haml
    module Javascript
      def render_with_options(text, options)
        compressor = ::YUI::JavaScriptCompressor.new(:munge => true)
        data = compressor.compress(text)
        %Q{<script type=#{options[:attr_wrapper]}text/javascript#{options[:attr_wrapper]}>#{data.chomp}</script>}
      end
    end
  end
end

Middleman::Features.register :minify_javascript, Middleman::Features::MinifyJavascript