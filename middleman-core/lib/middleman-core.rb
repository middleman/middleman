# Setup our load paths
libdir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# Top-level Middleman namespace
module Middleman

  # Backwards compatibility namespace
  module Features; end

  # Backwards compatible API for setting up the rack server
  #
  # @return [Middleman::Rack]
  def self.server(options={}, &block)
    require "middleman-core/rack/controller"
    ::Middleman::Rack::Controller.new(options, &block)
  end

end

require "middleman-core/version"
require "middleman-core/util"
require "middleman-core/extensions"
require "middleman-core/application"
