require 'zlib'
require 'stringio'
require 'find'

module Middleman
  module Extensions
  
    # This extension Gzips assets and pages when building. 
    # Gzipped assets and pages can be served directly by Apache or
    # Nginx with the proper configuration, and pre-zipping means that we
    # can use a more agressive compression level at no CPU cost per request.
    #
    # Use Nginx's gzip_static directive, or AddEncoding and mod_rewrite in Apache
    # to serve your Gzipped files whenever the normal (non-.gz) filename is requested.
    #
    # Pass the :exts options to customize which file extensions get zipped (defaults
    # to .html, .htm, .js and .css.
    #
    class Gzip < ::Middleman::Extension
      def after_build(builder)
        exts = @options[:exts] || %w(.js .css .html .htm)
        paths = ::Middleman::Util.all_files_under(app.build_dir)
        paths.each do |path|
          next unless exts.include? path.extname
        
          output_filename, old_size, new_size = gzip_file(path.to_s)

          if output_filename
            size_change_word = (old_size - new_size) > 0 ? 'smaller' : 'larger'
            builder.say_status :gzip, "#{output_filename} (#{app.number_to_human_size((old_size - new_size).abs)} #{size_change_word})"
          end
        end
      end
      
      def gzip_file(path)
        input_file = File.open(path, 'rb').read
        output_filename = path + '.gz'
        input_file_time = File.mtime(path)

        # Check if the right file's already there
        if File.exist?(output_filename) && File.mtime(output_filename) == input_file_time
          return
        end

        File.open(output_filename, 'wb') do |f|
          gz = Zlib::GzipWriter.new(f, Zlib::BEST_COMPRESSION)
          gz.mtime = input_file_time.to_i
          gz.write input_file
          gz.close
        end

        # Make the file times match, both for Nginx's gzip_static extension
        # and so we can ID existing files. Also, so even if the GZ files are
        # wiped out by build --clean and recreated, we won't rsync them over
        # again because they'll end up with the same mtime.
        File.utime(File.atime(output_filename), input_file_time, output_filename)

        old_size = File.size(path)
        new_size = File.size(output_filename)
      
        [output_filename, old_size, new_size]
      end
    end
  end
end
