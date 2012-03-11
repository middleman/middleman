require 'zlib'
require 'stringio'
require 'find'

module Middleman::Extensions
  
  # This extension Gzips assets when building. 
  # Gzipped assets can be served directly by Apache or
  # Nginx with the proper configuration, and pre-zipping means that we
  # can use a more agressive compression level at no CPU cost per request.
  #
  # Use Nginx's gzip_static directive, or AddEncoding and mod_rewrite in Apache
  # to serve your Gzipped files whenever the normal (non-.gz) filename is requested.
  #
  # Pass the :exts options to customize which file extensions get zipped (defaults
  # to .html, .htm, .js and .css.
  #
  module GzipAssets
    class << self
      def registered(app, options={})
        exts = options[:exts] || %w(.js .css .html .htm)
        
        app.send :include, InstanceMethods

        app.after_build do |builder|
          Find.find(self.class.inst.build_dir) do |path|
            next if File.directory? path
            if exts.include? File.extname(path)
              new_size = gzip_file(path, builder)
            end
          end
        end
      end
        
      alias :included :registered
    end

    module InstanceMethods
      def gzip_file(path, builder)
        input_file = File.open(path, 'r').read
        output_filename = path + '.gz'
        File.open(output_filename, 'w') do |f|
          gz = Zlib::GzipWriter.new(f, Zlib::BEST_COMPRESSION)
          gz.write input_file
          gz.close
        end

        old_size = File.size(path)
        new_size = File.size(output_filename)

        size_change_word = (old_size - new_size) > 0 ? 'smaller' : 'larger'

        builder.say_status :gzip, "#{output_filename} (#{number_to_human_size((old_size - new_size).abs)} #{size_change_word})"
      end
    end
  end
end
