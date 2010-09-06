module Middleman
  module Assets
    @@asset_handler_map   = []
    @@asset_handler_stack = []
    
    def self.register(handler_name, &block)
      if block_given?
        @@asset_handler_stack << block
        @@asset_handler_map   << handler_name
      end
    end
    
    def self.get_url(path, prefix="", request=nil)
      @@asset_handler_stack.last.call(path, prefix, request)
    end
    
    def self.before(position, *args)
      current_index = @@asset_handler_map.index(position)
      return nil unless current_index

      previous = current_index - 1
      if (previous >= 0) && (previous < @@asset_handler_map.length)
        @@asset_handler_stack[previous].call(*args)
      else
        nil
      end
    end
  end
end

Middleman::Assets.register :base do |path, prefix, request|
  path.include?("://") ? path : File.join(Middleman::Server.http_prefix || "/", prefix, path)
end