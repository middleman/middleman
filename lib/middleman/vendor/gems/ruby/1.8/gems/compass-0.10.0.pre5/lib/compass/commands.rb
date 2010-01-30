module Compass::Commands
end

require 'compass/commands/registry'

%w(base generate_grid_background help list_frameworks project_base
   update_project watch_project create_project installer_command
   print_version project_stats stamp_pattern validate_project
   write_configuration interactive).each do |lib|
  require "compass/commands/#{lib}"
end
