module FSSM::Backends
  class Inotify
    def initialize
      @notifier = INotify::Notifier.new
    end

    def add_handler(handler, preload=true)
      @notifier.watch(handler.path.to_s, :all_events) do |event|
        handler.refresh(event.name)
      end

      handler.refresh(nil, true) if preload
    end

    def run
      begin
        @notifier.run
      rescue Interrupt
      end
    end

  end
end
