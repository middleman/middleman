module Middleman::Extensions
  module DirectoryIndexes
    class << self
      def registered(app)
        app.send :include, InstanceMethods
        app.before do
          prefix           = @original_path.sub(/\/$/, "")
          indexed_path     = prefix + "/" + index_file
          extensioned_path = prefix + File.extname(index_file)
          
          is_ignored       = false
          fm_ignored       = false
          
          if sitemap.exists?(@original_path)
            d = sitemap.page(@original_path).data
            if !d.nil? && d.has_key?("directory_index") && d["directory_index"] == false
              fm_ignored = true
            else
              next
            end
          else
            is_ignored = ignored_directory_indexes.include?(extensioned_path)
          end

          if !sitemap.exists?(indexed_path) && !is_ignored && !fm_ignored
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
          frontmatter_ignore = false

          if sitemap.exists?(request_path)
            p = sitemap.page(request_path)
            d = p.data
            if !d.nil?
              frontmatter_ignore = d.has_key?("directory_index") && d["directory_index"] == false
            end
          end

          if ignored_directory_indexes.include?(request_path)
            false
          elsif request_path =~ /#{new_index_path}$/
            false
          elsif frontmatter_ignore
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
  
  register :directory_indexes, DirectoryIndexes
end