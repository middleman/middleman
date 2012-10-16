require "rack/builder"
require "middleman-core/watcher"

module Middleman
  module Rack
    
    # The Rack API to controlling Middleman
    class Controller
      
      attr_reader :middleman_app, :rack_app, :watcher
      
      def initialize(options={}, &block)
        @options = options
        @config_block = block
        
        reload_instance!
        
        # Register watcher responder
        if options[:watcher]
          @watcher = ::Middleman::Watcher.new(@options)
          @watcher.on_change(&method(:on_change))
          @watcher.on_delete(&method(:on_delete))
          @watcher.on_reload(&method(:reload_instance!))
          @watcher.start
        end
      end
      
      delegate :call, :to => :rack_app
      delegate :logger, :to => :middleman_app
      
      def on_change(path)
        @middleman_app.files.did_change(path)
      end
      
      def on_delete(path)
        @middleman_app.files.did_delete(path)
      end
      
      def reload_instance!
        if @middleman_app
          # TODO: Cleanup old instances?
        end

        @middleman_app = ::Middleman::Application.new(&@config_block)
        @rack_app = to_rack_app(@middleman_app)
      end

      def shutdown
        if options[:watcher]
          @watcher.stop
        end
      end
      
    protected

      # Return built Rack app
      #
      # @private
      # @return [Rack::Builder]
      def to_rack_app(middleman_app)
        rack_app = ::Rack::Builder.new

        (middleman_app.middleware || []).each do |m|
          rack_app.use(m[0], *m[1], &m[2])
        end

        rack_app.map("/") { run middleman_app }

        (middleman_app.mappings || []).each do |m|
          rack_app.map(m[0], &m[1])
        end

        rack_app
      end
    end
  end
end