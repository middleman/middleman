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
class Middleman::Extensions::Gzip < ::Middleman::Extension
  option :exts, %w(.js .css .html .htm), 'File extensions to Gzip when building.'
  option :ignore, [], 'Patterns to avoid gzipping'

  def initialize(app, options_hash={})
    super

    require 'zlib'
    require 'stringio'
    require 'find'
    require 'thread'
  end

  def after_build(builder)
    num_threads = 4
    paths = ::Middleman::Util.all_files_under(app.build_dir)
    total_savings = 0

    # Fill a queue with inputs
    in_queue = Queue.new
    paths.each do |path|
      in_queue << path if should_gzip?(path)
    end
    num_paths = in_queue.size

    # Farm out gzip tasks to threads and put the results in in_queue
    out_queue = Queue.new
    num_threads.times.each do
      Thread.new do
        while path = in_queue.pop
          out_queue << gzip_file(path.to_s)
        end
      end
    end

    # Insert a nil for each thread to stop it
    num_threads.times do
      in_queue << nil
    end

    old_locale = I18n.locale
    I18n.locale = :en # use the english localizations for printing out file sizes to make sure the localizations exist

    num_paths.times do
      output_filename, old_size, new_size = out_queue.pop

      next unless output_filename

      total_savings += (old_size - new_size)
      size_change_word = (old_size - new_size) > 0 ? 'smaller' : 'larger'
      builder.say_status :gzip, "#{output_filename} (#{app.number_to_human_size((old_size - new_size).abs)} #{size_change_word})"
    end

    builder.say_status :gzip, "Total gzip savings: #{app.number_to_human_size(total_savings)}", :blue
    I18n.locale = old_locale
  end

  def gzip_file(path)
    input_file = File.open(path, 'rb').read
    output_filename = path + '.gz'
    input_file_time = File.mtime(path)

    # Check if the right file's already there
    if File.exist?(output_filename) && File.mtime(output_filename) == input_file_time
      return [nil, nil, nil]
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

  private

  # Whether a path should be gzipped
  # @param [Pathname] path A destination path
  # @return [Boolean]
  def should_gzip?(path)
    options.exts.include?(path.extname) && options.ignore.none? { |ignore| Middleman::Util.path_match(ignore, path.to_s) }
  end
end
