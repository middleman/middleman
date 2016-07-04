# rubocop:disable FileName

# Top-level Middleman namespace
module Middleman
  # Backwards compatibility namespace
  module Features; end
end

require 'middleman-core/version'
require 'middleman-core/util'
require 'middleman-core/extensions'
require 'middleman-core/application' unless defined?(::Middleman::Application)
