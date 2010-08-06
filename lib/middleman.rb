libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'

module Middleman
  
  module Rack
    autoload :Sprockets, "middleman/rack/sprockets"
    autoload :MinifyJavascript, "middleman/rack/minify_javascript"
    autoload :MinifyCSS, "middleman/rack/minify_css"
  end

  module Renderers
    autoload :ERb,     "middleman/renderers/erb"
    autoload :Builder, "middleman/renderers/builder"
    autoload :Less,    "middleman/renderers/less"
  end
  
  autoload :Base,    "middleman/base"
  autoload :Haml,    "middleman/renderers/haml"
  autoload :Sass,    "middleman/renderers/sass"
  autoload :Helpers, "middleman/helpers"
  
end
