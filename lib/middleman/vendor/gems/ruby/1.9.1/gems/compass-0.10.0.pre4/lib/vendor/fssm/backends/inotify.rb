module FSSM::Backends
  class Inotify
    def initialize
      @notifier = INotify::Notifier.new
    end

    def add_path(path, preload=true)
      handler = FSSM::State.new(path)

      @notifier.watch(path.to_s, :all_events) do |event|
        handler.refresh(event.name)
      end

      handler.refresh(path.to_pathname, true) if preload
    end

    def run
      begin
        @notifier.run
      rescue Interrupt
      end
    end

  end
end
