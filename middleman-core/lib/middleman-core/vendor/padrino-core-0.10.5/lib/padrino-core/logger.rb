# Defines the log level for a Padrino project.
PADRINO_LOG_LEVEL = ENV['PADRINO_LOG_LEVEL'] unless defined?(PADRINO_LOG_LEVEL)
# Defines the logger used for a Padrino project.
PADRINO_LOGGER    = ENV['PADRINO_LOGGER'] unless defined?(PADRINO_LOGGER)

module Padrino

  ##
  # @return [Padrino::Logger]
  #
  # @example
  #   logger.debug "foo"
  #   logger.warn "bar"
  #
  def self.logger
    Padrino::Logger.setup! if Thread.current[:padrino_logger].nil?
    Thread.current[:padrino_logger]
  end

  ##
  # Set the padrino logger
  #
  # @param [Object] value
  #   an object that respond to <<, write, puts, debug, warn etc..
  #
  # @return [Object]
  #   the given value
  #
  # @example using ruby default logger
  #   require 'logger'
  #   Padrino.logger = Logger.new(STDOUT)
  #
  # @example using ActiveSupport
  #   require 'active_support/buffered_logger'
  #   Padrino.logger = Buffered.new(STDOUT)
  #
  def self.logger=(value)
    Thread.current[:padrino_logger] = value
  end

  ##
  # Extensions to the built in Ruby logger.
  #
  class Logger

    attr_accessor :level
    attr_accessor :auto_flush
    attr_reader   :buffer
    attr_reader   :log
    attr_reader   :init_args
    attr_accessor :log_static

    ##
    # Ruby (standard) logger levels:
    #
    # :fatal:: An unhandleable error that results in a program crash
    # :error:: A handleable error condition
    # :warn:: A warning
    # :info:: generic (useful) information about system operation
    # :debug:: low-level information for developers
    #
    Levels = {
      :fatal =>  7,
      :error =>  6,
      :warn  =>  4,
      :info  =>  3,
      :debug =>  0,
      :devel => -1,
    } unless const_defined?(:Levels)

    @@mutex = {}

    ##
    # Configuration for a given environment, possible options are:
    #
    # :log_level:: Once of [:fatal, :error, :warn, :info, :debug]
    # :stream:: Once of [:to_file, :null, :stdout, :stderr] our your custom stream
    # :log_level::
    #   The log level from, e.g. :fatal or :info. Defaults to :warn in the
    #   production environment and :debug otherwise.
    # :auto_flush::
    #   Whether the log should automatically flush after new messages are
    #   added. Defaults to true.
    # :format_datetime:: Format of datetime. Defaults to: "%d/%b/%Y %H:%M:%S"
    # :format_message:: Format of message. Defaults to: ""%s - - [%s] \"%s\"""
    # :log_static:: Whether or not to show log messages for static files. Defaults to: false
    #
    # @example
    #   Padrino::Logger::Config[:development] = { :log_level => :debug, :stream => :to_file }
    #   # or you can edit our defaults
    #   Padrino::Logger::Config[:development][:log_level] = :error
    #   # or you can use your stream
    #   Padrino::Logger::Config[:development][:stream] = StringIO.new
    #
    # Defaults are:
    #
    #   :production  => { :log_level => :warn, :stream => :to_file }
    #   :development => { :log_level => :debug, :stream => :stdout }
    #   :test        => { :log_level => :fatal, :stream => :null }
    #
    # In some cases, configuring the loggers before loading the framework is necessary.
    # You can do so by setting PADRINO_LOGGER:
    #
    #   PADRINO_LOGGER = { :staging => { :log_level => :debug, :stream => :to_file }}
    #
    Config = {
      :production  => { :log_level => :warn,  :stream => :to_file },
      :development => { :log_level => :debug, :stream => :stdout, :format_datetime => ' ' },
      :test        => { :log_level => :debug, :stream => :null }
    }
    Config.merge!(PADRINO_LOGGER) if PADRINO_LOGGER

    # Colors for levels
    ColoredLevels = {
      :fatal => [:bold, :red],
      :error => [:red],
      :warn  => [:yellow],
      :info  => [:green],
      :debug => [:cyan],
      :devel => [:magenta]
    } unless defined?(ColoredLevels)

    ##
    # Setup a new logger
    #
    # @return [Padrino::Logger]
    #   A {Padrino::Logger} instance
    #
    def self.setup!
      config_level = (PADRINO_LOG_LEVEL || Padrino.env || :test).to_sym # need this for PADRINO_LOG_LEVEL
      config = Config[config_level]

      unless config
        warn("No logging configuration for :#{config_level} found, falling back to :production")
        config = Config[:production]
      end

      stream = case config[:stream]
        when :to_file
          FileUtils.mkdir_p(Padrino.root("log")) unless File.exists?(Padrino.root("log"))
          File.new(Padrino.root("log", "#{Padrino.env}.log"), "a+")
        when :null   then StringIO.new
        when :stdout then $stdout
        when :stderr then $stderr
        else config[:stream] # return itself, probabilly is a custom stream.
      end
      Thread.current[:padrino_logger] = Padrino::Logger.new(config.merge(:stream => stream))
    end

    ##
    # To initialize the logger you create a new object, proxies to set_log.
    #
    # @param [Hash] options
    #
    # @option options [Symbol] :stream ($stdout)
    #   Either an IO object or a name of a logfile. Defaults to $stdout
    #
    # @option options [Symbol] :log_level (:production in the production environment and :debug otherwise)
    #   The log level from, e.g. :fatal or :info.
    #
    # @option options [Symbol] :auto_flush (true)
    #   Whether the log should automatically flush after new messages are
    #   added. Defaults to true.
    #
    # @option options [Symbol] :format_datetime (" [%d/%b/%Y %H:%M:%S] ")
    #   Format of datetime
    #
    # @option options [Symbol] :format_message ("%s -%s%s")
    #    Format of message
    #
    # @option options [Symbol] :log_static (false)
    #   Whether or not to show log messages for static files.
    #
    def initialize(options={})
      @buffer          = []
      @auto_flush      = options.has_key?(:auto_flush) ? options[:auto_flush] : true
      @level           = options[:log_level] ? Levels[options[:log_level]] : Levels[:debug]
      @log             = options[:stream]  || $stdout
      @log.sync        = true
      @mutex           = @@mutex[@log] ||= Mutex.new
      @format_datetime = options[:format_datetime] || "%d/%b/%Y %H:%M:%S"
      @format_message  = options[:format_message]  || "%s -%s%s"
      @log_static      = options.has_key?(:log_static) ? options[:log_static] : false
    end

    ##
    # Colorize our level
    #
    # @param [String, Symbol] level
    #
    # @see Padrino::Logger::ColoredLevels
    #
    def colored_level(level)
      style = ColoredLevels[level].map { |c| "\e[%dm" % String.colors[c] } * ''
      [style, level.to_s.upcase.rjust(7), "\e[0m"] * ''
    end

    ##
    # Flush the entire buffer to the log object.
    #
    def flush
      return unless @buffer.size > 0
      @mutex.synchronize do
        @log.write(@buffer.slice!(0..-1).join(''))
      end
    end

    ##
    # Close and remove the current log object.
    #
    # @return [NilClass]
    #
    def close
      flush
      @log.close if @log.respond_to?(:close) && !@log.tty?
      @log = nil
    end

    ##
    # Appends a message to the log. The methods yield to an optional block and
    # the output of this block will be appended to the message.
    #
    # @param [String] message
    #   The message that you want write to your stream
    #
    # @param [String] level
    #   The level one of :debug, :warn etc...
    #
    #
    def push(message = nil, level = nil)
      write @format_message % [colored_level(level), Time.now.strftime(@format_datetime).yellow, message.to_s.strip]
    end

    ##
    # Append a to development logger a given action with time
    #
    # @param [string] action
    #   The action
    #
    # @param [float] time
    #   Time duration for the given action
    #
    # @param [message] string
    #   The message that you want to log
    #
    # @example
    #   logger.bench 'GET', started_at, '/blog/categories'
    #   # => DEBUG - GET (0.056ms) - /blog/categories
    #
    def bench(action, began_at, message, level=:debug, color=:yellow)
      @_pad  ||= 8
      @_pad    = action.to_s.size if action.to_s.size > @_pad
      duration = Time.now - began_at
      color    = :red if duration > 1
      push "%s (" % action.to_s.upcase.rjust(@_pad).send(color) + "%0.4fms".bold.send(color) % duration + ") %s" % message.to_s, level
    end

    ##
    # Directly append message to the log.
    #
    # @param [String] message
    #   The message
    #
    def <<(message = nil)
      message << "\n" unless message[-1] == ?\n
      @buffer << message
      flush if @auto_flush
      message
    end
    alias :write :<<

    ##
    # Generate the logging methods for {Padrino.logger} for each log level.
    #
    Levels.each_pair do |name, number|
      define_method(name) do |*args|
        return if number < level
        if args.size > 1
          bench(*args)
        else
          push(args * '', name)
        end
      end

      define_method(:"#{name}?") do
        number >= level
      end
    end

    ##
    # Padrino::Loggger::Rack forwards every request to an +app+ given, and
    # logs a line in the Apache common log format to the +logger+, or
    # rack.errors by default.
    #
    class Rack

      def initialize(app, uri_root) # @private
        @app = app
        @uri_root = uri_root.sub(/\/$/,"")
      end

      def call(env) # @private
        env['rack.logger'] = Padrino.logger
        env['rack.errors'] = Padrino.logger.log
        began_at = Time.now
        status, header, body = @app.call(env)
        log(env, status, header, began_at)
        [status, header, body]
      end

      private
        def log(env, status, header, began_at)
          return if env['sinatra.static_file'] and !logger.log_static
          logger.bench(
            env["REQUEST_METHOD"],
            began_at,
            [
              @uri_root.to_s,
              env["PATH_INFO"],
              env["QUERY_STRING"].empty? ? "" : "?" + env["QUERY_STRING"],
              ' - ',
              status.to_s[0..3].bold,
              ' ',
              code_to_name(status)
            ] * '',
            :debug,
            :magenta
          )
        end

        def code_to_name(status)
          ::Rack::Utils::HTTP_STATUS_CODES[status.to_i] || ''
        end
    end # Rack
  end # Logger
end # Padrino

module Kernel # @private
  ##
  # Define a logger available every where in our app
  #
  def logger
    Padrino.logger
  end
end # Kernel
