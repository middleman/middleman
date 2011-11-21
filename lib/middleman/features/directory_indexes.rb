module Middleman::Features::DirectoryIndexes
  class << self
    def registered(app)
      app.send :include, InstanceMethods
      app.before do
        prefix         = @original_path.sub(/\/$/, "")
        indexed_path   = prefix + "/" + index_file
        
        extensioned_path = prefix + File.extname(index_file)
        is_ignored = ignored_directory_indexes.include?(extensioned_path)
        
        if !sitemap.exists?(indexed_path) && !is_ignored
          parts         = @original_path.split("/")
          last_part     = parts.last
          last_part_ext = File.extname(last_part)
        
          if last_part_ext.blank?
            # This is a folder, redirect to index
            @request_path = extensioned_path
          end
        end
      end
      
      app.build_reroute do |destination, request_path|
        index_ext      = File.extname(index_file)
        new_index_path = "/#{index_file}"
      
        indexed_path = request_path.sub(/\/$/, "") + index_ext
        
        if ignored_directory_indexes.include?(request_path)
          false
        elsif request_path =~ /#{new_index_path}$/
          false
        else
          [
            destination.sub(/#{index_ext.gsub(".", "\\.")}$/, new_index_path),
            request_path
          ]
        end
      end
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