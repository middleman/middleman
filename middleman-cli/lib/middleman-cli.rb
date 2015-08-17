# rubocop:disable FileName

# Setup our load paths
libdir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

# Require Thor since that's what the whole CLI is built around
require 'thor'

# CLI Module
module Middleman::Cli
  # The base task from which everything else extends
  class Base < ::Thor
    desc 'version', 'Show version'
    def version
      say "Middleman #{Middleman::VERSION}"
    end

    def self.exit_on_failure?
      true
    end
  end
end

# Require the Middleman version
require 'middleman-core/version'

# Include the core CLI items
require 'middleman-cli/init'
require 'middleman-cli/extension'
require 'middleman-cli/server'
require 'middleman-cli/build'
require 'middleman-cli/console'
require 'middleman-cli/config'
