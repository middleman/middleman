require "yaml"

module Middleman::Features::Data
  class << self
    def registered(app)
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
      file_path = File.join(@app.class.root, "data", "#{path}.yml")      
      if File.exists? file_path
        return YAML.load_file(file_path)
      end
    end
  end
  
end