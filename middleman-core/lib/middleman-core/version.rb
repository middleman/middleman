# Using for version parsing
require "rubygems"

module Middleman
  # Current Version
  # @return [String]
  VERSION = '3.0.0.alpha.8' unless const_defined?(:VERSION)
  
  # Parsed version for RubyGems
  # @private
  # @return [String]
  GEM_VERSION = ::Gem::Version.create(VERSION) unless const_defined?(:GEM_VERSION)
end