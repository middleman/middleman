require "yaml"
require "active_support/json"
require "thor"

module Middleman::CoreExtensions::Data
  class << self
    def registered(app)
      app.set :data_dir, "data"
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def initialize
      file_changed DataStore.matcher do |file|
        data.touch_file(file) if file.match(%r{^#{data_dir}\/})
      end
    
      file_deleted DataStore.matcher do |file|
        data.remove_file(file) if file.match(%r{^#{data_dir}\/})
      end
      
      super
    end
    
    def data
      @data ||= DataStore.new(self)
    end

    # Makes a hash available on the data var with a given name
    def data_content(name, content)
      DataStore.data_content(name, content)
    end

    # Makes a hash available on the data var with a given name
    def data_callback(name, &block)
      DataStore.data_callback(name, block)
    end
  end
  
  class DataStore
    def self.matcher
      %r{[\w-]+\.(yml|yaml|json)$}
    end
    
    def initialize(app)
      @app = app
      @local_data = {}
    end
    
    def touch_file(file)
      file = File.expand_path(file, @app.root)
      extension = File.extname(file)
      basename  = File.basename(file, extension)
      
      if %w(.yaml .yml).include?(extension)
        data = YAML.load_file(file)
      elsif extension == ".json"
        data = ActiveSupport::JSON.decode(File.read(file))
      else
        return
      end

      # @app.logger.debug :data_update, Time.now, basename if @app.logging?
      @local_data[basename] = recursively_enhance(data)
    end
    
    def remove_file(file)
      extension = File.extname(file)
      basename  = File.basename(file, extension)
      @local_data.delete(basename) if @local_data.has_key?(basename)
    end
    
    def data_for_path(path)
      response = nil
      
      @@local_sources ||= {}
      @@callback_sources ||= {}
      
      if @@local_sources.has_key?(path.to_s)
        response = @@local_sources[path.to_s]
      elsif @@callback_sources.has_key?(path.to_s)
        response = @@callback_sources[path.to_s].call()
      end
      
      response
    end
    
    def method_missing(path)
      if @local_data.has_key?(path.to_s)
        return @local_data[path.to_s]
      else
        result = data_for_path(path)
      
        if result
          return recursively_enhance(result)
        end
      end
      
      super
    end
    
    def to_h
      data = {}
      
      @@local_sources ||= {}
      @@callback_sources ||= {}
      
      (@@local_sources || {}).each do |k, v|
        data[k] = data_for_path(k)
      end
      
      (@@callback_sources || {}).each do |k, v|
        data[k] = data_for_path(k)
      end
      
      (@local_data || {}).each do |k, v|
        data[k] = v
      end
      
      data
    end

    def self.data_content(name, content)
      @@local_sources ||= {}
      @@local_sources[name.to_s] = content
    end
    
    def self.data_callback(name, proc)
      @@callback_sources ||= {}
      @@callback_sources[name.to_s] = proc
    end
  
  private
    def recursively_enhance(data)
      if data.is_a? Hash
        data = Thor::CoreExt::HashWithIndifferentAccess.new(data)
        data.each do |key, val|
          data[key] = recursively_enhance(val)
        end
        data
      elsif data.is_a? Array
        data.each_with_index do |val, i|
          data[i] = recursively_enhance(val)
        end
        data
      else
        data
      end
    end
  end
end