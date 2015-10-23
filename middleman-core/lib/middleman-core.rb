# rubocop:disable FileName

# Top-level Middleman namespace
module Middleman
  # Backwards compatibility namespace
  module Features; end

  autoload :Application, 'middleman-core/application'
end

require 'middleman-core/version'
require 'middleman-core/util'
require 'middleman-core/extensions'
