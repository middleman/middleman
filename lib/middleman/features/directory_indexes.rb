module Middleman::Features::DirectoryIndexes
  class << self
    def registered(app)
      app.set :ignored_directory_indexes, []
      app.extend ClassMethods
      
      app.build_reroute do |destination, request_path|
        indexed_path = request_path.gsub(/\/$/, "") + ".html"
        
        if app.settings.ignored_directory_indexes.include?(request_path)
          false
        else
          [
            destination.gsub(/\.html$/, "/index.html"),
            request_path.gsub(/\.html$/, "/index.html")
          ]
        end
      end
      
      app.before do
        indexed_path = request.path_info.gsub(/\/$/, "") + ".html"
        
        if !settings.ignored_directory_indexes.include?(indexed_path)
          parts = request.path_info.split("/")
          last_part = parts.last
          last_part_ext = File.extname(last_part)
        
          if last_part_ext.blank?
            # This is a folder, redirect to index
            request.path_info = indexed_path
          end
        end
      end
    end
    alias :included :registered
  end
  
  module ClassMethods
    def page(url, options={}, &block)
      if options.has_key?(:directory_index) && !options["directory_index"]
        settings.ignored_directory_indexes << url
      else
        super
      end
    end
  end
end