dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir unless $LOAD_PATH.include?(dir)

module FSSM
  FileNotFoundError = Class.new(StandardError)
  CallbackError = Class.new(StandardError)
  
  class << self
    def dbg(msg=nil)
      STDERR.puts(msg)
    end

    def monitor(*args, &block)      
      monitor = FSSM::Monitor.new
      context = args.empty? ? monitor : monitor.path(*args)

      if block_given?
        if block.arity == 1
          block.call(context)
        else
          context.instance_eval(&block)
        end
      end

      monitor.run
    end
  end
end

require 'thread'
require 'pathname'

require 'fssm/ext'
require 'fssm/support'
require 'fssm/tree'
require 'fssm/path'
require 'fssm/state'
require 'fssm/monitor'

require "fssm/backends/#{FSSM::Support.backend.downcase}"
FSSM::Backends::Default = FSSM::Backends.const_get(FSSM::Support.backend)
