# Watcher Library
require 'listen'
require 'middleman-core/contracts'
require 'digest'
require 'set'

# Monkey patch Listen silencer so `only` works on directories too
module Listen
  class Silencer
    # TODO: switch type and path places - and verify
    def silenced?(relative_path, _type)
      path = relative_path.to_s

      # if only_patterns && type == :file
      #   return true unless only_patterns.any? { |pattern| path =~ pattern }
      # end

      return !only_patterns.any? { |pattern| path =~ pattern } if only_patterns

      ignore_patterns.any? { |pattern| path =~ pattern }
    end
  end
end

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
    Contract Symbol
    attr_reader :type

    # The directory that is being watched
    Contract Pathname
    attr_reader :directory

    # Options for configuring the watcher
    Contract Hash
    attr_reader :options

    # Reference to lower level listener
    attr_reader :listener

    IGNORED_DIRECTORIES = Set.new(%w(.git node_modules .sass-cache vendor/bundle .bundle))

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

      @frontmatter = options.fetch(:frontmatter, true)
      @binary = options.fetch(:binary, false)
      @validator = options.fetch(:validator, proc { true })
      @ignored = options.fetch(:ignored, proc { false })
      @only = Array(options.fetch(:only, []))

      @disable_watcher = app.build?
      @force_polling = false
      @latency = nil
      @wait_for_delay = nil

      @listener = nil

      @callbacks = ::Middleman::CallbackManager.new
      @callbacks.install_methods!(self, [:on_change])

      @waiting_for_existence = !@directory.exist?
    end

    # Change the path of the watcher (if config values upstream change).
    #
    # @param [String] directory The new path.
    # @return [void]
    Contract String => Any
    def update_path(directory)
      @directory = Pathname(File.expand_path(directory, app.root))

      without_listener_running do
        update([], @files.values.map { |source_file| source_file[:full_path] })
      end

      poll_once!
    end

    def update_config(options={})
      without_listener_running do
        @disable_watcher = options.fetch(:disable_watcher, false)
        @force_polling = options.fetch(:force_polling, false)
        @latency = options.fetch(:latency, nil)
        @wait_for_delay = options.fetch(:wait_for_delay, nil)
      end
    end

    # Stop watching.
    #
    # @return [void]
    Contract Any
    def unwatch
      stop_listener!
    end

    # All the known files in this watcher.
    #
    # @return [Array<Middleman::SourceFile>]
    Contract ArrayOf[IsA['Middleman::SourceFile']]
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
      path = path.to_s.encode!('UTF-8', 'UTF-8-MAC') if RUBY_PLATFORM =~ /darwin/

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
    Contract Any
    def listen!
      return if @disable_watcher || @listener || @waiting_for_existence

      config = {
        force_polling: @force_polling
      }

      config[:wait_for_delay] = @wait_for_delay.try(:to_f) || 0.5
      config[:latency] = @latency.to_f if @latency

      @listener = ::Listen.to(@directory.to_s, config, &method(:on_listener_change))

      @listener.ignore(/^\.sass-cache/)
      @listener.ignore(/^node_modules/)
      @listener.ignore(/^vendor\/bundle/)

      @listener.start
    end

    # Stop the listener.
    #
    # @return [void]
    Contract Any
    def stop_listener!
      return unless @listener

      @listener.stop
      @listener = nil
    end

    Contract ArrayOf[Pathname]
    def find_new_files!
      new_files = ::Middleman::Util.all_files_under(@directory.to_s, &method(:should_not_recurse?))
                                   .reject { |p| @files.key?(p) }

      update(new_files, []).flatten.map { |s| s[:full_path] }
    end

    # Manually trigger update events.
    #
    # @return [void]
    Contract ArrayOf[Pathname]
    def poll_once!
      updated = ::Middleman::Util.all_files_under(@directory.to_s, &method(:should_not_recurse?))
      removed = @files.keys - updated

      result = update(updated, removed)

      if @waiting_for_existence && @directory.exist?
        @waiting_for_existence = false
        listen!
      end

      result.flatten.map { |s| s[:full_path] }
    end

    # Work around this bug: http://bugs.ruby-lang.org/issues/4521
    # where Ruby will call to_s/inspect while printing exception
    # messages, which can take a long time (minutes at full CPU)
    # if the object is huge or has cyclic references, like this.
    def to_s
      "#<Middleman::SourceWatcher:0x#{object_id} type=#{@type.inspect} directory=#{@directory.inspect}>"
    end
    alias inspect to_s # Ruby 2.0 calls inspect for NoMethodError instead of to_s

    protected

    Contract Pathname => Bool
    def should_not_recurse?(p)
      relative_path = p.relative_path_from(@directory).to_s
      IGNORED_DIRECTORIES.include?(relative_path)
    end

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
    Contract ArrayOf[Pathname], ArrayOf[Pathname] => ArrayOf[ArrayOf[IsA['Middleman::SourceFile']]]
    def update(updated_paths, removed_paths)
      valid_updates = updated_paths
                      .map { |p| @files[p] || path_to_source_file(p, @directory, @type, @options[:destination_dir]) }
                      .select(&method(:valid?))

      valid_updates.each do |f|
        record_file_change(f)
        logger.debug "== Change (#{f[:types].inspect}): #{f[:relative_path]}"
      end

      related_sources = valid_updates.map { |u| u[:full_path] } + removed_paths
      related_updates = ::Middleman::Util.find_related_files(app, related_sources).select(&method(:valid?))

      related_updates.each do |f|
        logger.debug "== Possible Change (#{f[:types].inspect}): #{f[:relative_path]}"
      end

      valid_updates |= related_updates

      valid_removes = removed_paths
                      .select(&@files.method(:key?))
                      .map(&@files.method(:[]))
                      .select(&method(:valid?))
                      .each do |f|
                        remove_file_from_cache(f)
                        logger.debug "== Deletion (#{f[:types].inspect}): #{f[:relative_path]}"
                      end

      unless valid_updates.empty? && valid_removes.empty?
        execute_callbacks(:on_change, [
                            valid_updates,
                            valid_removes,
                            self
                          ])
      end

      [valid_updates, valid_removes]
    end

    # Convert a path to a file resprentation.
    #
    # @param [Pathname] path The path.
    # @return [Middleman::SourceFile]
    Contract Pathname, Pathname, Symbol, Maybe[String] => ::Middleman::SourceFile
    def path_to_source_file(path, directory, type, destination_dir)
      types = Set.new([type])
      types << :no_frontmatter unless @frontmatter
      types << :binary if @binary

      relative_path = path.relative_path_from(directory)
      relative_path = File.join(destination_dir, relative_path) if destination_dir

      types << :no_frontmatter if partial?(relative_path.to_s)

      ::Middleman::SourceFile.new(Pathname(relative_path), path, directory, types, 0)
    end

    def partial?(relative_path)
      relative_path.split(::File::SEPARATOR).any? { |p| p.start_with?('_') }
    end

    Contract IsA['Middleman::SourceFile'] => Any
    def record_file_change(f)
      if @files[f[:full_path]]
        @files[f[:full_path]][:version] += 1
      else
        @files[f[:full_path]] = f
        @extensionless_files[strip_extensions(f[:full_path])] = f
      end
    end

    Contract IsA['Middleman::SourceFile'] => Any
    def remove_file_from_cache(f)
      @files.delete(f[:full_path])
      @extensionless_files.delete(strip_extensions(f[:full_path]))
    end

    Contract Pathname => Pathname
    def strip_extensions(p)
      p = p.sub_ext('') while ::Tilt[p.to_s] || p.extname == '.html'
      Pathname(p.to_s + '.*')
    end

    # Check if this watcher should care about a file.
    #
    # @param [Middleman::SourceFile] file The file.
    # @return [Boolean]
    Contract IsA['Middleman::SourceFile'] => Bool
    def valid?(file)
      return false unless @validator.call(file) && !globally_ignored?(file)

      if @only.empty?
        !@ignored.call(file)
      else
        @only.any? { |reg| file[:relative_path].to_s =~ reg }
      end
    end

    private

    def without_listener_running
      listener_running = @listener && @listener.processing?

      stop_listener! if listener_running

      yield

      if listener_running
        poll_once!
        listen!
      end
    end
  end
end
