# Watcher Library
require 'listen'
require 'middleman-core/contracts'

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
      @only = Array(options.fetch(:only, []))

      @disable_watcher = app.build? || @parent.options.fetch(:disable_watcher, false)
      @force_polling = @parent.options.fetch(:force_polling, false)
      @latency = @parent.options.fetch(:latency, nil)

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
      @directory = Pathname(directory)

      stop_listener! if @listener

      update([], @files.values)

      poll_once!

      listen! unless @disable_watcher
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
        force_polling: @force_polling,
        wait_for_delay: 0.5
      }

      config[:latency] = @latency if @latency

      @listener = ::Listen.to(@directory.to_s, config, &method(:on_listener_change))

      @listener.ignore(/^\.sass-cache/)
      # @listener.only(@only) unless @only.empty?

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

    # Manually trigger update events.
    #
    # @return [void]
    Contract Any
    def poll_once!
      updated = ::Middleman::Util.all_files_under(@directory.to_s)
      removed = @files.keys.reject { |p| updated.include?(p) }

      update(updated, removed)

      return unless @waiting_for_existence && @directory.exist?

      @waiting_for_existence = false
      listen!
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
                      .map { |p| ::Middleman::Util.path_to_source_file(p, @directory, @type, @options.fetch(:destination_dir, false)) }
                      .select(&method(:valid?))

      valid_updates.each do |f|
        add_file_to_cache(f)
        logger.debug "== Change (#{f[:types].inspect}): #{f[:relative_path]}"
      end

      related_updates = ::Middleman::Util.find_related_files(app, (updated_paths + removed_paths)).select(&method(:valid?))

      related_updates.each do |f|
        logger.debug "== Possible Change (#{f[:types].inspect}): #{f[:relative_path]}"
      end

      valid_updates |= related_updates

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

      execute_callbacks(:on_change, [
        valid_updates,
        valid_removes,
        self
      ]) unless valid_updates.empty? && valid_removes.empty?
    end

    def add_file_to_cache(f)
      @files[f[:full_path]] = f
      @extensionless_files[strip_extensions(f[:full_path])] = f
    end

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
        @only.any? { |reg| reg.match(file[:relative_path].to_s) }
      end
    end
  end
end
