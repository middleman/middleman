require 'fssm/fsevents'

module FSSM::Backends
  class FSEvents
    def initialize
      @handlers = {}
      @fsevents = []
    end
    
    def add_path(path, preload=true)
      handler = FSSM::State.new(path)
      @handlers["#{path}"] = handler
      
      fsevent = Rucola::FSEvents.new("#{path}", {:latency => 0.5}) do |events|
        events.each do |event|
          handler.refresh(event.path)
        end
      end
      
      fsevent.create_stream
      handler.refresh(path.to_pathname, true) if preload
      fsevent.start
      @fsevents << fsevent
    end
    
    def run
      begin
        OSX.CFRunLoopRun
      rescue Interrupt
        @fsevents.each do |fsev|
          fsev.stop
        end
      end
    end

  end
end
