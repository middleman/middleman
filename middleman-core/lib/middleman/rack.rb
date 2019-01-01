require 'middleman-core/load_paths'
::Middleman.setup_load_paths

require 'middleman-core'
require 'middleman-core/rack'
require 'middleman-core/application'

module Middleman
  def self.server
    ::Middleman::Rack.new(::Middleman::Application.new)
  end
end
