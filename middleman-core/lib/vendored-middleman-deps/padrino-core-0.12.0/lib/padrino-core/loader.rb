module Padrino
  module Loader
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
    # Requires necessary dependencies as well as application files from root
    # lib and models.
    #
    # @return [Boolean]
    #   returns true if Padrino is not already bootstraped otherwise else.
    #
    def load!
      return false if loaded?
      began_at = Time.now
      @_called_from = first_caller
      set_encoding
      set_load_paths(*load_paths)
      Logger.setup!
      require_dependencies("#{root}/config/database.rb")
      Reloader.lock!
      before_load.each(&:call)
      require_dependencies(*dependency_paths)
      after_load.each(&:call)
      logger.devel "Loaded Padrino in #{Time.now - began_at} seconds"
      Thread.current[:padrino_loaded] = true
    end

    ##
    # Clear the padrino env.
    #
    # @return [NilClass]
    #
    def clear!
      clear_middleware!
      mounted_apps.clear
      @_load_paths = nil
      @_dependency_paths = nil
      @_global_configuration = nil
      before_load.clear
      after_load.clear
      Reloader.clear!
      Thread.current[:padrino_loaded] = nil
    end

    ##
    # Method for reloading required applications and their files.
    #
    def reload!
      return unless Reloader.changed?
      before_load.each(&:call)
      Reloader.reload!
      after_load.each(&:call)
    end

    ##
    # This adds the ability to instantiate {Padrino.load!} after
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
    # We get an error, because we try to require first +a.rb+ that need
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
      options = paths.extract_options!.merge( :cyclic => true )
      files = paths.flatten.map{|path| Dir[path].sort_by{|v| v.count('/') }}.flatten.uniq

      while files.present?
        error, fatal, loaded = nil, nil, nil

        files.dup.each do |file|
          begin
            Reloader.safe_load(file, options)
            files.delete(file)
            loaded = true
          rescue NameError, LoadError => e
            logger.devel "Cyclic dependency reload for #{e.class}: #{e.message}"
            error = e
          rescue Exception => e
            fatal = e
            break
          end
        end

        if fatal || !loaded
          e = fatal || error
          logger.error "#{e.class}: #{e.message}; #{e.backtrace.first}"
          raise e
        end
      end
    end

    ##
    # Concat to +$LOAD_PATH+ the given paths.
    #
    # @param [Array<String>] paths
    #   The paths to concat.
    #
    def set_load_paths(*paths)
      load_paths.concat(paths).uniq!
      $LOAD_PATH.concat(paths).uniq!
    end

    ##
    # The used +$LOAD_PATHS+ from Padrino.
    #
    # @return [Array<String>]
    #   The load paths used by Padrino.
    #
    def load_paths
      @_load_paths ||= load_paths_was.dup
    end

    ##
    # Returns default list of path globs to load as dependencies.
    # Appends custom dependency patterns to the be loaded for Padrino.
    #
    # @return [Array<String>]
    #   The dependencey paths.
    #
    # @example
    #   Padrino.dependency_paths << "#{Padrino.root}/uploaders/*.rb"
    #
    def dependency_paths
      @_dependency_paths ||= dependency_paths_was + module_paths
    end

    private

    def module_paths
      modules.map(&:dependency_paths).flatten
    end

    def load_paths_was
      @_load_paths_was ||= [
        "#{root}/lib",
        "#{root}/models",
        "#{root}/shared",
      ].freeze
    end

    def dependency_paths_was
      @_dependency_paths_was ||= [
        "#{root}/config/database.rb",
        "#{root}/lib/**/*.rb",
        "#{root}/models/**/*.rb",
        "#{root}/shared/lib/**/*.rb",
        "#{root}/shared/models/**/*.rb",
        "#{root}/config/apps.rb"
      ].freeze
    end
  end
end
