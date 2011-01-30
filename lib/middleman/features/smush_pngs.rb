module Middleman::Features::SmushPngs
  module ThorActions
    def smush_pngs
      # Read cache
      cache_file = File.join(Middleman::Server.root, ".smush-cache")
      cache_data = if File.exists?(cache_file)
        Marshal.restore(File.read(cache_file))
      else
        {}
      end
    
      smush_dir = File.join(Middleman::Server.build_dir, Middleman::Server.images_dir)
      
      files = ::Smusher.class_eval do
        images_in_folder(smush_dir)
      end
      
      files.each do |file|
        ::Smusher.class_eval do
          original_file_size = size(file)
          return if original_file_size.zero?
          return if cache_data[file] && cache_data[file] == original_file_size
          
          with_logging(file, true) do
            write_optimized_data(file)
            cache_data[file] = size(file) # Add or update cache
            File.open(cache_file, "w") { |f| f.write Marshal.dump(cache_data) } # Write cache
          end
        end
          
        say_status :smushed, file.gsub(Middleman::Server.build_dir+"/", "")
      end
    end
  end
  
  class << self
    def registered(app)
      require "middleman/builder"   
      require "smusher"
      require "json/pure"

      Middleman::Builder.send :include, ThorActions
      Middleman::Builder.after_run "smush_pngs" do
        smush_pngs
      end
    end
  end
end