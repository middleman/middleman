# Using a bunch of convenience methods
require "active_support"

# Setup our load paths
libdir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# Top-level Middleman namespace
module Middleman; end

require "middleman-core/version"
require "middleman-core/util"
require "middleman-core/extensions"
require "middleman-core/application"