require 'pathname'

module Padrino
  ##
  # High performance source code reloader middleware
  #
  module Reloader
    ##
    # This reloader is suited for use in a many environments because each file
    # will only be checked once and only one system call to stat(2) is made.
    #
    # Please note that this will not reload files in the background, and does so
    # only when explicitly invoked.
    #

    # The modification times for every file in a project.
    MTIMES          = {}
    # The list of files loaded as part of a project.
    LOADED_FILES    = {}
    # The list of object constants and classes loaded as part of the project.
    LOADED_CLASSES  = {}

    class << self
      ##
      # Specified folders can be excluded from the code reload detection process.
      # Default excluded directories at Padrino.root are: test, spec, features, tmp, config, db and public
      #
      def exclude
        @_exclude ||= %w(test spec tmp features config public db).map { |path| Padrino.root(path) }
      end

      ##
      # Specified constants can be excluded from the code unloading process.
      #
      def exclude_constants
        @_exclude_constants ||= Set.new
      end

      ##
      # Specified constants can be configured to be reloaded on every request.
      # Default included constants are: [none]
      #
      def include_constants
        @_include_constants ||= Set.new
      end

      ##
      # Reload all files with changes detected.
      #
      def reload!
        # Detect changed files
        rotation do |file, mtime|
          # Retrive the last modified time
          new_file       = MTIMES[file].nil?
          previous_mtime = MTIMES[file] ||= mtime
          logger.devel "Detected a new file #{file}" if new_file
          # We skip to next file if it is not new and not modified
          next unless new_file || mtime > previous_mtime
          # Now we can reload our file
          apps = mounted_apps_of(file)
          if apps.present?
            apps.each { |app| app.app_obj.reload! }
          else
            safe_load(file, :force => new_file)
            # Reload also apps
            Padrino.mounted_apps.each do |app|
              app.app_obj.reload! if app.app_obj.dependencies.include?(file)
            end
          end
        end
      end

      ##
      # Remove files and classes loaded with stat
      #
      def clear!
        clear_modification_times
        clear_loaded_classes
        clear_loaded_files_and_features
      end

      ##
      # Returns true if any file changes are detected and populates the MTIMES cache
      #
      def changed?
        changed = false
        rotation do |file, mtime|
          new_file = MTIMES[file].nil?
          previous_mtime = MTIMES[file]
          changed = true if new_file || mtime > previous_mtime
        end
        changed
      end
      alias :run! :changed?

      ##
      # We lock dependencies sets to prevent reloading of protected constants
      #
      def lock!
        klasses = ObjectSpace.classes do |klass|
          klass._orig_klass_name.split('::')[0]
        end

        klasses = klasses | Padrino.mounted_apps.map { |app| app.app_class }
        Padrino::Reloader.exclude_constants.merge(klasses)
      end

      ##
      # A safe Kernel::require which issues the necessary hooks depending on results
      #
      def safe_load(file, options={})
        began_at = Time.now
        force    = options[:force]
        file     = figure_path(file)
        reload   = should_reload?(file)
        m_time   = modification_time(file)

        return if !force && m_time && !reload

        remove_loaded_file_classes(file)
        remove_loaded_file_features(file)

        # Duplicate objects and loaded features before load file
        klasses = ObjectSpace.classes
        files   = Set.new($LOADED_FEATURES.dup)

        reload_deps_of_file(file)

        # And finally load the specified file
        begin
          logger.devel :loading, began_at, file if !reload
          logger.debug :reload,  began_at, file if  reload

          $LOADED_FEATURES.delete(file) if files.include?(file)
          Padrino::Utils.silence_output
          loaded = false
          require(file)
          loaded = true
          update_modification_time(file)
        rescue SyntaxError => e
          logger.error "Cannot require #{file} due to a syntax error: #{e.message}"
        ensure
          Padrino::Utils.unsilence_output
          new_constants = ObjectSpace.new_classes(klasses)
          if loaded
            process_loaded_file(:file      => file, 
                                :constants => new_constants, 
                                :files     => files)
          else
            logger.devel "Failed to load #{file}; removing partially defined constants"
            unload_constants(new_constants)
          end
        end
      end

      ##
      # Returns true if the file is defined in our padrino root
      #
      def figure_path(file)
        return file if Pathname.new(file).absolute?
        $:.each do |path|
          found = File.join(path, file)
          return File.expand_path(found) if File.exist?(found)
        end
        file
      end

      ##
      # Removes the specified class and constant.
      #
      def remove_constant(const)
        return if exclude_constants.any? { |c| const._orig_klass_name.index(c) == 0 } &&
                 !include_constants.any? { |c| const._orig_klass_name.index(c) == 0 }
        begin
          parts  = const.to_s.sub(/^::(Object)?/, 'Object::').split('::')
          object = parts.pop
          base   = parts.empty? ? Object : Inflector.constantize(parts * '::')
          base.send :remove_const, object
          logger.devel "Removed constant: #{const} from #{base}"
        rescue NameError; end
      end

      private

      ###
      # Clear instance variables that keep track of 
      # loaded features/files/mtimes
      #
      def clear_modification_times
        MTIMES.clear
      end
      
      def clear_loaded_classes
        LOADED_CLASSES.each do |file, klasses|
          klasses.each { |klass| remove_constant(klass) }
          LOADED_CLASSES.delete(file)
        end
      end

      def clear_loaded_files_and_features
        LOADED_FILES.each do |file, dependencies|
          dependencies.each { |dependency| $LOADED_FEATURES.delete(dependency) }
          $LOADED_FEATURES.delete(file)
        end
      end

      ###
      # Macro for mtime query
      #
      def modification_time(file)
        MTIMES[file]
      end

      ###
      # Macro for mtime update
      #
      def update_modification_time(file)
        MTIMES[file] = File.mtime(file)
      end

      ###
      # Tracks loaded file features/classes/constants
      #
      def process_loaded_file(*args)
        options       = args.extract_options!
        new_constants = options[:constants]
        files         = options[:files]
        file          = options[:file]

        # Store the file details
        LOADED_CLASSES[file] = new_constants
        LOADED_FILES[file]   = Set.new($LOADED_FEATURES) - files - [file]

        # Track only features in our Padrino.root
        LOADED_FILES[file].delete_if { |feature| !in_root?(feature) }
      end

      ###
      # Unloads all constants in new_constants
      #
      def unload_constants(new_constants)
        new_constants.each { |klass| remove_constant(klass) }
      end

      ###
      # Safe load dependencies of a file
      #
      def reload_deps_of_file(file)
        if features = LOADED_FILES.delete(file)
          features.each { |feature| safe_load(feature, :force => true) }
        end
      end

      ##
      # Check if file was changed or if force a reload
      #
      def should_reload?(file)
        MTIMES[file] && File.mtime(file) > MTIMES[file]
      end

      ##
      # Removes all classes declared in the specified file
      #
      def remove_loaded_file_classes(file)
        if klasses = LOADED_CLASSES.delete(file)
          klasses.each { |klass| remove_constant(klass) }
        end 
      end

      ##
      # Remove all loaded fatures with our file
      #
      def remove_loaded_file_features(file)
        if features = LOADED_FILES[file]
          features.each { |feature| $LOADED_FEATURES.delete(feature) }
        end
      end

      ##
      # Return the mounted_apps providing the app location
      # Can be an array because in one app.rb we can define multiple Padrino::Appplications
      #
      def mounted_apps_of(file)
        file = figure_path(file)
        Padrino.mounted_apps.find_all { |app| File.identical?(file, app.app_file) }
      end

      ##
      # Returns true if file is in our Padrino.root
      #
      def in_root?(file)
        # This is better but slow:
        #   Pathname.new(Padrino.root).find { |f| File.identical?(Padrino.root(f), figure_path(file)) }
        figure_path(file).index(Padrino.root) == 0
      end

      ##
      # Searches Ruby files in your +Padrino.load_paths+ , Padrino::Application.load_paths
      # and monitors them for any changes.
      #
      def rotation
        files_for_rotation.uniq.map do |file|
          file = File.expand_path(file)
          next if Padrino::Reloader.exclude.any? { |base| file.index(base) == 0 } || !File.exist?(file)
          yield file, File.mtime(file)
        end.compact
      end

      ##
      # Creates an array of paths for use in #rotation
      #
      def files_for_rotation
        files  = Padrino.load_paths.map { |path| Dir["#{path}/**/*.rb"] }.flatten
        files  = files | Padrino.mounted_apps.map { |app| app.app_file }
        files  = files | Padrino.mounted_apps.map { |app| app.app_obj.dependencies }.flatten
      end
    end # self

    ##
    # This class acts as a Rack middleware to be added to the application stack. This middleware performs a
    # check and reload for source files at the start of each request, but also respects a specified cool down time
    # during which no further action will be taken.
    #
    class Rack
      def initialize(app, cooldown=1)
        @app = app
        @cooldown = cooldown
        @last = (Time.now - cooldown)
      end

      # Invoked in order to perform the reload as part of the request stack.
      def call(env)
        if @cooldown && Time.now > @last + @cooldown
          Thread.list.size > 1 ? Thread.exclusive { Padrino.reload! } : Padrino.reload!
          @last = Time.now
        end
        @app.call(env)
      end
    end
  end # Reloader
end # Padrino
