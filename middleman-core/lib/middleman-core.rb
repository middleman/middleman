# Setup our load paths
libdir = __dir__
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'backports/latest'
require 'active_support/all'

# Top-level Middleman namespace
module Middleman
  autoload :Application, 'middleman-core/application'
end

require 'middleman-core/util/empty_hash'
require 'middleman-core/version'
require 'middleman-core/util'
require 'middleman-core/extensions'
