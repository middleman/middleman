class FSEvent
  class << self
    class_eval <<-END
      def root_path
        "#{File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))}"
      end
    END
    class_eval <<-END
      def watcher_path
        "#{File.join(FSEvent.root_path, 'bin', 'fsevent_watch')}"
      end
    END
  end

  attr_reader :paths, :callback

  def watch(watch_paths, options=nil, &block)
    @paths      = watch_paths.kind_of?(Array) ? watch_paths : [watch_paths]
    @callback   = block

    if options.kind_of?(Hash)
      @options  = parse_options(options)
    elsif options.kind_of?(Array)
      @options  = options
    else
      @options  = []
    end
  end

  def run
    @running = true
    # please note the use of IO::select() here, as it is used specifically to
    # preserve correct signal handling behavior in ruby 1.8.
    while @running && IO::select([pipe], nil, nil, nil)
      if line = pipe.readline
        modified_dir_paths = line.split(":").select { |dir| dir != "\n" }
        callback.call(modified_dir_paths)
      end
    end
  rescue Interrupt, IOError
  ensure
    stop
  end

  def stop
    if pipe
      Process.kill("KILL", pipe.pid)
      pipe.close
    end
  rescue IOError
  ensure
    @pipe = @running = nil
  end

  if RUBY_VERSION < '1.9'
    def pipe
      @pipe ||= IO.popen("#{self.class.watcher_path} #{options_string} #{shellescaped_paths}")
    end

    private

    def options_string
      @options.join(' ')
    end

    def shellescaped_paths
      @paths.map {|path| shellescape(path)}.join(' ')
    end

    # for Ruby 1.8.6  support
    def shellescape(str)
      # An empty argument will be skipped, so return empty quotes.
      return "''" if str.empty?

      str = str.dup

      # Process as a single byte sequence because not all shell
      # implementations are multibyte aware.
      str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

      # A LF cannot be escaped with a backslash because a backslash + LF
      # combo is regarded as line continuation and simply ignored.
      str.gsub!(/\n/, "'\n'")

      return str
    end
  else
    def pipe
      @pipe ||= IO.popen([self.class.watcher_path] + @options + @paths)
    end
  end

  private

  def parse_options(options={})
    opts = []
    opts.concat(['--since-when', options[:since_when]]) if options[:since_when]
    opts.concat(['--latency', options[:latency]]) if options[:latency]
    opts.push('--no-defer') if options[:no_defer]
    opts.push('--watch-root') if options[:watch_root]
    # ruby 1.9's IO.popen(array-of-stuff) syntax requires all items to be strings
    opts.map {|opt| "#{opt}"}
  end

end
