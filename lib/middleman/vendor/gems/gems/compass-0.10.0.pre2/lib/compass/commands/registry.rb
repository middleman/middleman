module Compass::Commands
  module Registry
    def register(name, command_class)
      @commands ||= Hash.new
      @commands[name.to_sym] = command_class
    end
    def get(name)
      @commands ||= Hash.new
      @commands[name.to_sym]
    end
    def command_exists?(name)
      @commands ||= Hash.new
      name && @commands.has_key?(name.to_sym)
    end
    def all
      @commands.keys
    end
    alias_method :[], :get
    alias_method :[]=, :register
  end
  extend Registry
end
