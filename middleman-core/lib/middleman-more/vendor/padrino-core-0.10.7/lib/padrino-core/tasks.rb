module Padrino
  ##
  # This module it's used for bootstrap with padrino rake
  # thirdy party tasks, in your gem/plugin/extension you
  # need only do this:
  #
  # @example
  #   Padrino::Tasks.files << yourtask.rb
  #   Padrino::Tasks.files.concat(Dir["/path/to/all/my/tasks/*.rb"])
  #   Padrino::Tasks.files.unshift("yourtask.rb")
  #
  module Tasks

    ##
    # Returns a list of files to handle with padrino rake
    #
    def self.files
      @files ||= []
    end
  end # Tasks
end # Padrino
