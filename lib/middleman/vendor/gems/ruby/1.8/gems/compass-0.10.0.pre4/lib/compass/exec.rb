require 'compass/dependencies'
require 'optparse'
require 'compass/logger'
require 'compass/errors'
require 'compass/actions'
require 'compass/installers'
require 'compass/commands'

module Compass::Exec
end

%w(helpers switch_ui sub_command_ui
   global_options_parser project_options_parser
   command_option_parser).each do |lib|
  require "compass/exec/#{lib}"
end
