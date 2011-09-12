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
      self.class.data
    end
  end
  
  class DataObject
    def initialize(app)
      @app = app
    end
    
    def data_for_path(path)
      response = nil
      
      @@local_sources ||= {}
      @@callback_sources ||= {}
      
      if @@local_sources.has_key?(path.to_s)
        response = @@local_sources[path.to_s]
      elsif @@callback_sources.has_key?(path.to_s)
        response = @@callback_sources[path.to_s].call()
      else
        file_path = File.join(@app.root, @app.data_dir, "#{path}.yml")
        if File.exists? file_path
          response = YAML.load_file(file_path) 
        else
          file_path = File.join(@app.root, @app.data_dir, "#{path}.yaml")
          response = YAML.load_file(file_path) if File.exists? file_path
        end
      end
      
      response
    end
    
    def method_missing(path)
      result = data_for_path(path)
      
      if result
        recursively_enhance(result)
      else
        super
      end
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
      
      yaml_path = File.join(@app.root, @app.data_dir, "*.{yaml,yml}")
      Dir[yaml_path].each do |f|
        p = f.split("/").last.gsub(".yml", "").gsub(".yaml", "")
        data[p] = data_for_path(p)
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
  
  module ClassMethods
    def data
      @data ||= DataObject.new(self)
    end
    
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