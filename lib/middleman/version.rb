# Using for version parsing
require "rubygems"

module Middleman
  # Current Version
  # @return [String]
  VERSION = "3.0.0.alpha.4"
  
  # Parsed version for RubyGems
  # @private
  # @return [String]
  GEM_VERSION = ::Gem::Version.create(VERSION)
end
