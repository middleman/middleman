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
        @_exclude_constants ||= []
      end

      ##
      # Specified constants can be configured to be reloaded on every request.
      # Default included constants are: [none]
      #
      def include_constants
        @_include_constants ||= []
      end

      ##
      # Reload all files with changes detected.
      #
      def reload!
        # Detect changed files
        rotation do |file, mtime|
          # Retrive the last modified time
          new_file = MTIMES[file].nil?
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
        MTIMES.clear
        LOADED_CLASSES.each do |file, klasses|
          klasses.each { |klass| remove_constant(klass) }
          LOADED_CLASSES.delete(file)
        end
        LOADED_FILES.each do |file, dependencies|
          dependencies.each { |dependency| $LOADED_FEATURES.delete(dependency) }
          $LOADED_FEATURES.delete(file)
        end
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
        klasses = ObjectSpace.classes.map { |klass| klass._orig_klass_name.split('::')[0] }.uniq
        klasses = klasses | Padrino.mounted_apps.map { |app| app.app_class }
        Padrino::Reloader.exclude_constants.concat(klasses)
      end

      ##
      # A safe Kernel::require which issues the necessary hooks depending on results
      #
      def safe_load(file, options={})
        began_at    = Time.now
        force, file = options[:force], figure_path(file)

        # Check if file was changed or if force a reload
        reload = MTIMES[file] && File.mtime(file) > MTIMES[file]
        return if !force && !reload && MTIMES[file]

        # Removes all classes declared in the specified file
        if klasses = LOADED_CLASSES.delete(file)
          klasses.each { |klass| remove_constant(klass) }
        end

        # Remove all loaded fatures with our file
        if features = LOADED_FILES[file]
          features.each { |feature| $LOADED_FEATURES.delete(feature) }
        end

        # Duplicate objects and loaded features before load file
        klasses = ObjectSpace.classes.dup
        files   = $LOADED_FEATURES.dup

        # Now we can reload dependencies of our file
        if features = LOADED_FILES.delete(file)
          features.each { |feature| safe_load(feature, :force => true) }
        end

        # And finally load the specified file
        begin
          logger.devel :loading, began_at, file if !reload
          logger.debug :reload,  began_at, file if  reload
          $LOADED_FEATURES.delete(file)
          verbosity_was, $-v = $-v, nil
          loaded = false
          require(file)
          loaded = true
          MTIMES[file] = File.mtime(file)
        rescue SyntaxError => e
          logger.error "Cannot require #{file} due to a syntax error: #{e.message}"
        ensure
          $-v = verbosity_was
          new_constants = (ObjectSpace.classes - klasses).uniq
          if loaded
            # Store the file details
            LOADED_CLASSES[file] = new_constants
            LOADED_FILES[file]   = ($LOADED_FEATURES - files - [file]).uniq
            # Track only features in our Padrino.root
            LOADED_FILES[file].delete_if { |feature| !in_root?(feature) }
          else
            logger.devel "Failed to load #{file}; removing partially defined constants"
            new_constants.each { |klass| remove_constant(klass) }
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
        return if exclude_constants.compact.uniq.any? { |c| const._orig_klass_name.index(c) == 0 } &&
                 !include_constants.compact.uniq.any? { |c| const._orig_klass_name.index(c) == 0 }
        begin
          parts  = const.to_s.sub(/^::(Object)?/, 'Object::').split('::')
          object = parts.pop
          base   = parts.empty? ? Object : Inflector.constantize(parts * '::')
          base.send :remove_const, object
          logger.devel "Removed constant: #{const} from #{base}"
        rescue NameError; end
      end

      private
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
        files  = Padrino.load_paths.map { |path| Dir["#{path}/**/*.rb"] }.flatten
        files  = files | Padrino.mounted_apps.map { |app| app.app_file }
        files  = files | Padrino.mounted_apps.map { |app| app.app_obj.dependencies }.flatten
        files.uniq.map do |file|
          file = File.expand_path(file)
          next if Padrino::Reloader.exclude.any? { |base| file.index(base) == 0 } || !File.exist?(file)
          yield file, File.mtime(file)
        end.compact
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
