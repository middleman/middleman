# Extensions namespace
module Middleman::Extensions
  
  # Directory Indexes extension
  module DirectoryIndexes
    
    # class DirectoryIndexMiddleware < ::Middleman::Sitemap::Middleware
    #   def call(env)
    #     index_file = @sitemap.app.index_file
    #     
    #     paths = env.map do |path|
    #       new_index_path = "/#{index_file}"
    #   
    #       # Check if it would be pointless to reroute
    #       page_already_index = path == index_file || path.end_with?(new_index_path)
    #       if page_already_index || File.extname(index_file) != File.extname(path)
    #         path
    #       else
    #         path.chomp(File.extname(index_file)) + new_index_path
    #       end
    #     end
    # 
    #     $stderr.puts "DI: #{paths.length}"
    #     @app.call(paths)
    #   end
    # end
    
    # Setup extension
    class << self
      
      # Once registered
      def registered(app)
        # app.after_configuration do
        #   # sitemap.add_path_middleware(DirectoryIndexMiddleware)
        # 
        #   
        #   # Register a reroute transform that turns regular paths into indexed paths
        #   sitemap.reroute do |destination, page|
        #     new_index_path = "/#{index_file}"
        # 
        #     # Check if it would be pointless to reroute
        #     path = page.path
        #     page_already_index = path == index_file || path.end_with?(new_index_path)
        #     if page_already_index || File.extname(index_file) != File.extname(path)
        #       next destination
        #     end
        # 
        #     # Check if frontmatter turns directory_index off
        #     d = page.data
        #     next destination if d && d["directory_index"] == false
        # 
        #     # Check if file metadata (options set by "page" in config.rb) turns directory_index off
        #     # TODO: This is crazy - we need a generic way to get metadata for paths
        #     # page.metadata
        #     metadata_ignore = false
        #     provides_metadata_for_path.each do |callback, matcher|
        #       if matcher.is_a? Regexp
        #         next if !path.match(matcher)
        #       elsif matcher.is_a? String
        #         next if !File.fnmatch("/" + matcher.sub(%r{^/}, ''), "/#{path}")
        #       end
        #       
        #       result = instance_exec(path, &callback)
        #       if result[:options] && result[:options][:directory_index] == false
        #         metadata_ignore = true
        #         break
        #       end
        #     end
        # 
        #     next destination if metadata_ignore
        # 
        #     # Not ignored, so reroute
        #     destination.chomp(File.extname(index_file)) + new_index_path
        #   end
        # end
      end

      alias :included :registered
    end
  end
  
  # Register the extension
  register :directory_indexes, DirectoryIndexes
end
