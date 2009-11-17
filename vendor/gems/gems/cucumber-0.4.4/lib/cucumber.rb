$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'yaml'
require 'cucumber/platform'
require 'cucumber/parser'
require 'cucumber/step_mother'
require 'cucumber/cli/main'
require 'cucumber/broadcaster'

module Cucumber
  class << self
    attr_accessor :wants_to_quit
  end
end