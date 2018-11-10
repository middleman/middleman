# Setup our load paths
libdir = __dir__
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'backports/latest'

# Top-level Middleman namespace
module Middleman
  EMPTY_HASH = {}.freeze

  autoload :Application, 'middleman-core/application'
end

require 'middleman-core/version'
require 'middleman-core/util'
require 'middleman-core/extensions'
