# require "fssm"
require "yaml"

module Middleman::Features::Data
  class << self
    def registered(app)
      @@app = app
      @@data_structure = {}
      
      Dir[File.join(app.root, 'data/*.yml')].each do |d|
        handle_update(d)
      end
      
      # FSSM.monitor(app.root, 'data/*.yml') do
      #   update do |base, relative|
      #     handle_update(File.join(base, relative))
      #   end
      #   
      #   create do |base, relative|
      #     handle_update(File.join(base, relative))
      #   end
      # 
      #   delete do |base, relative|
      #     handle_delete(File.join(base, relative))
      #   end
      # end
    end
    
    def handle_update(path)
      data_name = File.basename(path).split(".").first
      data = YAML.load_file(path)
      
      @@data_structure[data_name] = data
      @@app.set :data, @@data_structure
    end

    # def handle_delete(path)
    #   data_name = File.basename(path).split(".").first
    #   @@data_structure.delete(data_name) if @@data_structure.has_key? data_name
    #   @@app.set :data, @@data_structure
    # end
    
    alias :included :registered
  end
end