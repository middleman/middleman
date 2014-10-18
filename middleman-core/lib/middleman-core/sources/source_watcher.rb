# Watcher Library
require 'listen'
require 'middleman-core/contracts'
require 'backports/2.0.0/enumerable/lazy'

module Middleman
  # The default source watcher implementation. Watches a directory on disk
  # and responds to events on changes.
  class SourceWatcher
    extend Forwardable
    include Contracts

    # References to parent `Sources` app and `globally_ignored?` check.
    def_delegators :@parent, :app, :globally_ignored?

    # Reference to the singleton logger
    def_delegator :app, :logger

    # The type this watcher is representing
    Contract None => Symbol
    attr_reader :type

    # The directory that is being watched
    Contract None => Pathname
    attr_reader :directory

    # Options for configuring the watcher
    Contract None => Hash
    attr_reader :options

    IMAGE_EXTENSIONS = %w(.png .jpg .jpeg .webp .svg .svgz .gif)
    FONT_EXTENSIONS = %w(.otf .woff .eot .ttf)

    # Construct a new SourceWatcher
    #
    # @param [Middleman::Sources] parent The parent collection.
    # @param [Symbol] type The watcher type.
    # @param [String] directory The on-disk path to watch.
    # @param [Hash] options Configuration options.
    Contract IsA['Middleman::Sources'], Symbol, String, Hash => Any
    def initialize(parent, type, directory, options={})
      @parent = parent
      @options = options

      @type = type
      @directory = Pathname(directory)

      @files = {}
      @extensionless_files = {}

      @validator = options.fetch(:validator, proc { true })
      @ignored = options.fetch(:ignored, proc { false })

      @disable_watcher = app.build? || @parent.options.fetch(:disable_watcher, false)
      @force_polling = @parent.options.fetch(:force_polling, false)
      @latency = @parent.options.fetch(:latency, nil)

      @listener = nil

      @on_change_callbacks = Set.new

      @waiting_for_existence = !@directory.exist?
    end

    # Change the path of the watcher (if config values upstream change).
    #
    # @param [String] directory The new path.
    # @return [void]
    Contract String => Any
    def update_path(directory)
      @directory = Pathname(directory)

      stop_listener! if @listener

      update([], @files.values)

      poll_once!

      listen! unless @disable_watcher
    end

    # Stop watching.
    #
    # @return [void]
    Contract None => Any
    def unwatch
      stop_listener!
    end

    # All the known files in this watcher.
    #
    # @return [Array<Middleman::SourceFile>]
    Contract None => ArrayOf[IsA['Middleman::SourceFile']]
    def files
      @files.values
    end

    # Find a specific file in this watcher.
    #
    # @param [String, Pathname] path The search path.
    # @param [Boolean] glob If the path contains wildcard characters.
    # @return [Middleman::SourceFile, nil]
    Contract Or[String, Pathname], Maybe[Bool] => Maybe[IsA['Middleman::SourceFile']]
    def find(path, glob=false)
      p = Pathname(path)

      return nil if p.absolute? && !p.to_s.start_with?(@directory.to_s)

      p = @directory + p if p.relative?

      if glob
        @extensionless_files[p]
      else
        @files[p]
      end
    end

    # Check if a file simply exists in this watcher.
    #
    # @param [String, Pathname] path The search path.
    # @return [Boolean]
    Contract Or[String, Pathname] => Bool
    def exists?(path)
      !find(path).nil?
    end

    # Start the `listen` gem Listener.
    #
    # @return [void]
    Contract None => Any
    def listen!
      return if @disable_watcher || @listener || @waiting_for_existence

      config = { force_polling: @force_polling }
      config[:latency] = @latency if @latency

      @listener = ::Listen.to(@directory.to_s, config, &method(:on_listener_change))
      @listener.start
    end

    # Stop the listener.
    #
    # @return [void]
    Contract None => Any
    def stop_listener!
      return unless @listener

      @listener.stop
      @listener = nil
    end

    # Manually trigger update events.
    #
    # @return [void]
    Contract None => Any
    def poll_once!
      removed = @files.keys

      updated = []

      ::Middleman::Util.all_files_under(@directory.to_s).each do |filepath|
        removed.delete(filepath)
        updated << filepath
      end

      update(updated, removed)

      return unless @waiting_for_existence && @directory.exist?

      @waiting_for_existence = false
      listen!
    end

    # Add callback to be run on file change
    #
    # @param [Proc] matcher A Regexp to match the change path against
    # @return [Set<Proc>]
    Contract Proc => SetOf[Proc]
    def changed(&block)
      @on_change_callbacks << block
      @on_change_callbacks
    end

    # Work around this bug: http://bugs.ruby-lang.org/issues/4521
    # where Ruby will call to_s/inspect while printing exception
    # messages, which can take a long time (minutes at full CPU)
    # if the object is huge or has cyclic references, like this.
    def to_s
      "#<Middleman::SourceWatcher:0x#{object_id} type=#{@type.inspect} directory=#{@directory.inspect}>"
    end
    alias_method :inspect, :to_s # Ruby 2.0 calls inspect for NoMethodError instead of to_s

    protected

    # The `listen` gem callback.
    #
    # @param [Array] modified List of modified files.
    # @param [Array] added List of added files.
    # @param [Array] removed List of removed files.
    # @return [void]
    Contract Array, Array, Array => Any
    def on_listener_change(modified, added, removed)
      updated = (modified + added)

      return if updated.empty? && removed.empty?

      update(updated.map { |s| Pathname(s) }, removed.map { |s| Pathname(s) })
    end

    # Update our internal list of files on a change.
    #
    # @param [String, Pathname] path The updated file path.
    # @return [void]
    Contract ArrayOf[Pathname], ArrayOf[Pathname] => Any
    def update(updated_paths, removed_paths)
      valid_updates = updated_paths
          .lazy
          .map(&method(:path_to_source_file))
          .select(&method(:valid?))
          .to_a
          .each do |f|
            add_file_to_cache(f)
            logger.debug "== Change (#{f[:types].inspect}): #{f[:relative_path]}"
          end

      valid_removes = removed_paths
          .lazy
          .select(&@files.method(:key?))
          .map(&@files.method(:[]))
          .select(&method(:valid?))
          .to_a
          .each do |f|
            remove_file_from_cache(f)
            logger.debug "== Deletion (#{f[:types].inspect}): #{f[:relative_path]}"
          end

      run_callbacks(
        @on_change_callbacks,
        valid_updates,
        valid_removes
      ) unless valid_updates.empty? && valid_removes.empty?
    end

    def add_file_to_cache(f)
      @files[f[:full_path]] = f
      @extensionless_files[f[:full_path].sub_ext('.*')] = f
    end

    def remove_file_from_cache(f)
      @files.delete(f[:full_path])
      @extensionless_files.delete(f[:full_path].sub_ext('.*'))
    end

    # Check if this watcher should care about a file.
    #
    # @param [Middleman::SourceFile] file The file.
    # @return [Boolean]
    Contract IsA['Middleman::SourceFile'] => Bool
    def valid?(file)
      @validator.call(file) &&
      !globally_ignored?(file) &&
      !@ignored.call(file)
    end

    # Convert a path to a file resprentation.
    #
    # @param [Pathname] path The path.
    # @return [Middleman::SourceFile]
    Contract Pathname => IsA['Middleman::SourceFile']
    def path_to_source_file(path)
      types = Set.new([@type])

      if @type == :source
        types << :image if IMAGE_EXTENSIONS.include?(path.extname)
        types << :font if FONT_EXTENSIONS.include?(path.extname)
      end

      ::Middleman::SourceFile.new(
          path.relative_path_from(@directory), path, @directory, types)
    end

    # Notify callbacks for a file given an array of callbacks
    #
    # @param [Pathname] path The file that was changed
    # @param [Symbol] callbacks_name The name of the callbacks method
    # @return [void]
    Contract Set, ArrayOf[IsA['Middleman::SourceFile']], ArrayOf[IsA['Middleman::SourceFile']] => Any
    def run_callbacks(callbacks, updated_files, removed_files)
      callbacks.each do |callback|
        callback.call(updated_files, removed_files, self)
      end
    end
  end
end
