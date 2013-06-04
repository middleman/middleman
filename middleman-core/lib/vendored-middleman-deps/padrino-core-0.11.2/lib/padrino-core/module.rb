module Padrino
  module Module
    attr_accessor :root

    ##
    # Register this module as being loaded from a gem. This automatically
    # sets the root and therefore the dependency paths correctly.
    #
    # @param [String] name
    #   The name of the gem. Has to be the name as stated in the gemspec.
    #
    # @returns the gems root.
    def gem!(name)
      self.root = Padrino.gem(name, self)
    end

    ##
    # Helper method for file references within a Padrino module.
    #
    # @param [Array<String>] args
    #   The directories to join to {Module.root}.
    #
    # @return [String]
    #   The absolute path.
    #
    # @example
    #   module MyModule
    #     extend Padrino::Module
    #     gem! 'my_gem'
    #   end
    #   Module.root!
    def root(*args)
      File.expand_path(File.join(@root, *args))
    end
    
    ##
    # Returns the list of path globs to load as dependencies
    # Appends custom dependency patterns to the be loaded for Padrino.
    #
    # @return [Array<String>]
    #   The dependency paths.
    #
    # @example
    #   module MyModule
    #     extend Padrino::Module
    #     gem! 'my_gem'
    #   end
    #
    #   Module.dependency_paths << "#{MyModule.root}/uploaders/*.rb"
    #
    def dependency_paths
      [
        "#{root}/lib/**/*.rb", "#{root}/shared/lib/**/*.rb",
        "#{root}/models/**/*.rb", "#{root}/shared/models/**/*.rb"
      ]
    end
  end
end