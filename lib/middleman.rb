libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'rubygems'

module Middleman
  autoload :Server, "middleman/server"

  module Renderers
    autoload :Haml, "middleman/renderers/haml"
    autoload :Sass, "middleman/renderers/sass"
  end

  autoload :Features, "middleman/features"
end
