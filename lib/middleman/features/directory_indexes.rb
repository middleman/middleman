module Middleman::Features::DirectoryIndexes
  class << self
    def registered(app)
      app.send :include, InstanceMethods
      app.before do
        indexed_path   = env["PATH_INFO"].sub(/\/$/, "") + "/" + self.index_file
        indexed_exists = resolve_template(indexed_path)
      
        extensioned_path = env["PATH_INFO"].sub(/\/$/, "") + File.extname(self.index_file)
        is_ignored = self.ignored_directory_indexes.include?(extensioned_path)
        
        if !indexed_exists && !is_ignored
          parts         = env["PATH_INFO"].split("/")
          last_part     = parts.last
          last_part_ext = File.extname(last_part)
        
          if last_part_ext.blank?
            # This is a folder, redirect to index
            env["PATH_INFO"] = extensioned_path
          end
        end
      end
      
      # app.build_reroute do |destination, request_path|
      #         index_ext = File.extname(app.settings.index_file)
      #         new_index_path = "/#{app.settings.index_file}"
      #       
      #         indexed_path = request_path.gsub(/\/$/, "") + index_ext
      #         
      #         if app.settings.ignored_directory_indexes.include?(request_path)
      #           false
      #         elsif request_path =~ /#{new_index_path}$/
      #           false
      #         else
      #           [
      #             destination.gsub(/#{index_ext.gsub(".", "\\.")}$/, new_index_path),
      #             request_path
      #           ]
      #         end
      #       end
    end
    alias :included :registered
  end
  
  module InstanceMethods
    def ignored_directory_indexes
      @_ignored_directory_indexes ||= []
    end
    
    def page(url, options={}, &block)
      if options.has_key?(:directory_index) && !options["directory_index"]
        ignored_directory_indexes << url
      else
        super
      end
    end
  end
end