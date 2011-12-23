# Using for version parsing
require "rubygems"

module Middleman
  # Current Version
  # @return [String]
  VERSION = "3.0.0.alpha.6"
  
  # Parsed version for RubyGems
  # @private
  # @return [String]
  GEM_VERSION = ::Gem::Version.create(VERSION)
end
