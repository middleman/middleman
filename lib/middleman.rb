libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'

module Middleman
  
  module Rack
    autoload :Sprockets, "middleman/rack/sprockets"
    autoload :MinifyJavascript, "middleman/rack/minify_javascript"
    autoload :MinifyCSS, "middleman/rack/minify_css"
  end

  autoload :Base,    "middleman/base"
  autoload :Haml,    "middleman/haml"
  autoload :Helpers, "middleman/helpers"
  
end