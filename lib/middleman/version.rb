# Using for version parsing
require "rubygems"

module Middleman
  VERSION = "3.0.0.alpha.3"
  
  # @private
  GEM_VERSION = ::Gem::Version.create(VERSION)
end
