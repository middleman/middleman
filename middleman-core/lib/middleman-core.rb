# Setup our load paths
libdir = __dir__
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# Top-level Middleman namespace
module Middleman
  autoload :Application, 'middleman-core/application'
end

require 'middleman-core/version'
require 'middleman-core/util'
require 'middleman-core/extensions'
