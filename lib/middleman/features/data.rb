require "yaml"
require "httparty"
require "thor"

module Middleman::Features::Data
  class << self
    def registered(app)
      app.extend ClassMethods
      app.helpers Middleman::Features::Data::Helpers
    end
    alias :included :registered
  end
  
  module Helpers
    def data
      @@data ||= Middleman::Features::Data::DataObject.new(self)
    end
  end
  
  class DataObject
    def initialize(app)
      @app = app
    end
    
    def method_missing(path)
      response = nil
      
      @@remote_sources ||= {}
      if @@remote_sources.has_key?(path.to_s)
        response = HTTParty.get(@@remote_sources[path.to_s]).parsed_response
      end
      
      file_path = File.join(@app.class.root, "data", "#{path}.yml")      
      if File.exists? file_path
        response = YAML.load_file(file_path)
      end
      
      if response
        recursively_enhance(response)
      end
    end
    
    def self.add_source(name, json_url)
      @@remote_sources ||= {}
      @@remote_sources[name.to_s] = json_url
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
    # Makes HTTP json data available in the data object
    #
    #     data_source :my_json, "http://my/file.json"
    #
    # Available in templates as:
    #
    #     data.my_json
    def data_source(name, url)
      Middleman::Features::Data::DataObject.add_source(name, url)
    end
  end
end