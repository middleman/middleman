module Middleman::CoreExtensions::Assets
  class << self
    def registered(app)
      # Disable Padrino cache buster until explicitly enabled
      app.set :asset_stamp, false
      
      app.extend ClassMethods
      
      app.helpers Helpers
      
      app.register_asset_handler :base do |path, prefix, request|
        path.include?("://") ? path : File.join(app.http_prefix || "/", prefix, path)
      end
    end
    alias :included :registered
  end
  
  module ClassMethods    
    def register_asset_handler(handler_name, &block)
      @asset_handler_map   ||= []
      @asset_handler_stack ||= []
      
      if block_given?
        @asset_handler_stack << block
        @asset_handler_map   << handler_name
      end
    end
    
    def asset_handler_get_url(path, prefix="", request=nil)
      @asset_handler_map   ||= []
      @asset_handler_stack ||= []
      
      @asset_handler_stack.last.call(path, prefix, request)
    end
    
    def before_asset_handler(position, *args)
      @asset_handler_map   ||= []
      @asset_handler_stack ||= []
      
      current_index = @asset_handler_map.index(position)
      return nil unless current_index

      previous = current_index - 1
      if (previous >= 0) && (previous < @asset_handler_map.length)
        @asset_handler_stack[previous].call(*args)
      else
        nil
      end
    end
  end
  
  module Helpers
    def asset_url(path, prefix="")
      self.class.asset_handler_get_url(path, prefix, request)
    end
  end
end