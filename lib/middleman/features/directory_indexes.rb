module Middleman::Features::DirectoryIndexes
  class << self
    def registered(app)
      app.send :include, InstanceMethods
      app.before do
        prefix         = @original_path.sub(/\/$/, "")
        indexed_path   = prefix + "/" + self.index_file
        indexed_exists = resolve_template(indexed_path)
              
        extensioned_path = prefix + File.extname(self.index_file)
        is_ignored = self.ignored_directory_indexes.include?(extensioned_path)
        
        if !indexed_exists && !is_ignored
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
        index_ext      = File.extname(self.index_file)
        new_index_path = "/#{self.index_file}"
      
        indexed_path = request_path.sub(/\/$/, "") + index_ext
        
        if self.ignored_directory_indexes.include?(request_path)
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