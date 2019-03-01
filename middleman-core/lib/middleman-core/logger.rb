# Use the Ruby/Rails logger
module Middleman
  # The Middleman Logger
  class Logger < ::ActiveSupport::Logger
    def self.singleton(*args)
      if !@_logger || !args.empty?
        args = [0, false, args.first] if args.length == 1 && (args.first.is_a?(::String) || args.first.respond_to?(:write))
        @_logger = new(*args)
      end

      @_logger
    end

    def initialize(log_level = 1, is_instrumenting = false, target = $stdout)
      super(target)

      self.level = log_level
      @instrumenting = is_instrumenting

      ::ActiveSupport::Notifications.subscribe(/\.middleman$/, self) if @instrumenting != false

      @mutex = Mutex.new
    end

    def add(*args)
      @mutex.synchronize do
        super
      end
    end

    def call(message, *args)
      return if @instrumenting.is_a?(String) && @instrumenting != 'instrument' && !message.include?(@instrumenting)

      evt = ::ActiveSupport::Notifications::Event.new(message, *args)
      return unless evt.duration > 30

      info "== Instrument (#{evt.name.sub(/.middleman$/, '')}): #{evt.duration}ms\n#{args.last}"
    end
  end
end
