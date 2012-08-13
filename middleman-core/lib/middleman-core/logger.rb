# Use the Ruby/Rails logger
require 'active_support/core_ext/logger'
require "securerandom"

module Middleman

  # The Middleman Logger
  class Logger < ::Logger

    # Force output to STDOUT
    def initialize(log_level=1, is_instrumenting=false, target=STDOUT)
      super(STDOUT)

      self.level = log_level
      @instrumenting = is_instrumenting

      if @instrumenting != false
        ::ActiveSupport::Notifications.subscribe(/\.middleman$/, self)
      end
    end

    def call(message, *args)
      return if @instrumenting.is_a?(String) && @instrumenting != "instrument" && !message.include?(@instrumenting)

      evt = ActiveSupport::Notifications::Event.new(message, *args)
      self.info "== Instrument (#{evt.name.sub(/.middleman$/, '')}): #{evt.duration}ms"
    end
  end
end
