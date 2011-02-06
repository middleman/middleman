module Middleman::Features::MinifyJavascript
  class << self
    def registered(app)
      # Only do minification on build or prod mode
      return unless [:build, :production].include? app.environment
      
      Middleman::Features::MinifyJavascript::Haml::Javascript.send :include, ::Haml::Filters::Base

      require "middleman/features/minify_javascript/rack"
      app.use Middleman::Rack::MinifyJavascript
    end
    alias :included :registered
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