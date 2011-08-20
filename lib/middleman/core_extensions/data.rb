require "yaml"
require "thor"

module Middleman::CoreExtensions::Data
  class << self
    def registered(app)
      app.set :data_dir, "data"
      app.extend ClassMethods
      app.helpers Helpers
    end
    alias :included :registered
  end
  
  module Helpers
    def data
      @@data ||= DataObject.new(self)
    end
  end
  
  class DataObject
    def initialize(app)
      @app = app
    end
    
    def method_missing(path)
      response = nil
      
      @@local_sources ||= {}
      @@callback_sources ||= {}
      
      if @@local_sources.has_key?(path.to_s)
        response = @@local_sources[path.to_s]
      elsif @@callback_sources.has_key?(path.to_s)
        response = @@callback_sources[path.to_s].call()
      else
        file_path = File.join(@app.class.root, @app.class.data_dir, "#{path}.yml")
        if File.exists? file_path
          response = YAML.load_file(file_path)
        end
      end
      
      if response
        recursively_enhance(response)
      end
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
  
  module ClassMethods
    # Makes a hash available on the data var with a given name
    def data_content(name, content)
      DataObject.data_content(name, content)
    end
    
    # Makes a hash available on the data var with a given name
    def data_callback(name, &block)
      DataObject.data_callback(name, block)
    end
  end
end