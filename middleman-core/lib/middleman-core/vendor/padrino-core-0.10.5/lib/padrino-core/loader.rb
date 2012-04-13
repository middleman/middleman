module Padrino
  class << self
    ##
    # Hooks to be called before a load/reload.
    #
    # @yield []
    #   The given block will be called before Padrino was loaded/reloaded.
    #
    # @return [Array<Proc>]
    #   The load/reload before hooks.
    #
    # @example
    #   before_load do
    #     pre_initialize_something
    #   end
    #
    def before_load(&block)
      @_before_load ||= []
      @_before_load << block if block_given?
      @_before_load
    end

    ##
    # Hooks to be called after a load/reload.
    #
    # @yield []
    #   The given block will be called after Padrino was loaded/reloaded.
    #
    # @return [Array<Proc>]
    #   The load/reload hooks.
    #
    # @example
    #   after_load do
    #     DataMapper.finalize
    #   end
    #
    def after_load(&block)
      @_after_load ||= []
      @_after_load << block if block_given?
      @_after_load
    end

    ##
    # The used +$LOAD_PATHS+ from Padrino.
    #
    # @return [Array<String>]
    #   The load paths used by Padrino.
    #
    def load_paths
      @_load_paths_was = %w(lib models shared).map { |path| Padrino.root(path) }
      @_load_paths ||= @_load_paths_was
    end

    ##
    # Requires necessary dependencies as well as application files from root
    # lib and models.
    #
    # @return [Boolean]
    #   returns true if Padrino is not already bootstraped otherwise else.
    #
    def load!
      return false if loaded?
      @_called_from = first_caller
      Padrino.set_encoding
      Padrino.set_load_paths(*load_paths) # We set the padrino load paths
      Padrino::Logger.setup! # Initialize our logger
      Padrino.require_dependencies("#{root}/config/database.rb", :nodeps => true) # Be sure to don't remove constants from dbs.
      Padrino::Reloader.lock! # Now we can remove constant from here to down
      Padrino.before_load.each(&:call) # Run before hooks
      Padrino.dependency_paths.each { |path| Padrino.require_dependencies(path) }
      Padrino.after_load.each(&:call) # Run after hooks
      Padrino::Reloader.run!
      Thread.current[:padrino_loaded] = true
    end

    ##
    # Clear the padrino env.
    #
    # @return [NilClass]
    #
    def clear!
      Padrino.clear_middleware!
      Padrino.mounted_apps.clear
      @_load_paths = nil
      @_dependency_paths = nil
      @_global_configuration = nil
      Padrino.before_load.clear
      Padrino.after_load.clear
      Padrino::Reloader.clear!
      Thread.current[:padrino_loaded] = nil
    end

    ##
    # Method for reloading required applications and their files.
    #
    def reload!
      return unless Padrino::Reloader.changed?
      Padrino.before_load.each(&:call) # Run before hooks
      Padrino::Reloader.reload! # detects the modified files
      Padrino.after_load.each(&:call) # Run after hooks
    end

    ##
    # This adds the ablity to instantiate {Padrino.load!} after
    # {Padrino::Application} definition.
    #
    def called_from
      @_called_from || first_caller
    end

    ##
    # Determines whether Padrino was loaded with {Padrino.load!}.
    #
    # @return [Boolean]
    #   Specifies whether Padrino was loaded.
    #
    def loaded?
      Thread.current[:padrino_loaded]
    end

    ##
    # Attempts to require all dependency libs that we need.
    # If you use this method we can perform correctly a Padrino.reload!
    # Another good thing that this method are dependency check, for example:
    #
    #   # models
    #   #  \-- a.rb => require something of b.rb
    #   #  \-- b.rb
    #
    # In the example above if we do:
    #
    #   Dir["/models/*.rb"].each { |r| require r }
    #
    # we get an error, because we try to require first +a.rb+ that need
    # _something_ of +b.rb+.
    #
    # With this method we don't have this problem.
    #
    # @param [Array<String>] paths
    #   The paths to require.
    #
    # @example For require all our app libs we need to do:
    #   require_dependencies("#{Padrino.root}/lib/**/*.rb")
    #
    def require_dependencies(*paths)
      options = paths.extract_options!

      # Extract all files to load
      files = paths.flatten.map { |path| Dir[path] }.flatten.uniq.sort

      while files.present?
        # List of errors and failed files
        errors, failed = [], []

        # We need a size to make sure things are loading
        size_at_start = files.size

        # Now we try to require our dependencies, we dup files
        # so we don't perform delete on the original array during
        # iteration, this prevent problems with rubinus
        files.dup.each do |file|
          begin
            Padrino::Reloader.safe_load(file, options.dup)
            files.delete(file)
          rescue LoadError => e
            errors << e
            failed << file
          rescue NameError => e
            errors << e
            failed << file
          rescue Exception => e
            raise e
          end
        end

        # Stop processing if nothing loads or if everything has loaded
        raise errors.last if files.size == size_at_start && files.present?
        break if files.empty?
      end
    end

    ##
    # Returns default list of path globs to load as dependencies
    # Appends custom dependency patterns to the be loaded for Padrino.
    #
    # @return [Array<String>]
    #   The dependencey paths.
    #
    # @example
    #   Padrino.dependency_paths << "#{Padrino.root}/uploaders/*.rb"
    #
    def dependency_paths
      @_dependency_paths_was = [
        "#{root}/config/database.rb", "#{root}/lib/**/*.rb", "#{root}/shared/lib/**/*.rb",
        "#{root}/models/**/*.rb", "#{root}/shared/models/**/*.rb", "#{root}/config/apps.rb"
      ]
      @_dependency_paths ||= @_dependency_paths_was
    end

    ##
    # Concat to +$LOAD_PATH+ the given paths.
    #
    # @param [Array<String>] paths
    #   The paths to concat.
    #
    def set_load_paths(*paths)
      $:.concat(paths); load_paths.concat(paths)
      $:.uniq!; load_paths.uniq!
    end
  end # self
end # Padrino
