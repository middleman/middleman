module Compass
  module Actions

    attr_writer :logger

    def logger
      @logger ||= Logger.new
    end

    # copy/process a template in the compass template directory to the project directory.
    def copy(from, to, options = nil, binary = false)
      options ||= self.options if self.respond_to?(:options)
      contents = File.new(from).read
      write_file to, contents, options, binary
    end

    # create a directory and all the directories necessary to reach it.
    def directory(dir, options = nil)
      options ||= self.options if self.respond_to?(:options)
      if File.exists?(dir) && File.directory?(dir)
          logger.record :exists, basename(dir) unless options[:quiet]
      elsif File.exists?(dir)
        msg = "#{basename(dir)} already exists and is not a directory."
        raise Compass::FilesystemConflict.new(msg)
      else
        logger.record :directory, separate("#{basename(dir)}/")
        FileUtils.mkdir_p(dir) unless options[:dry_run]
      end
    end

    # Write a file given the file contents as a string
    def write_file(file_name, contents, options = nil, binary = false)
      options ||= self.options if self.respond_to?(:options)
      skip_write = options[:dry_run]
      if File.exists?(file_name)
        existing_contents = IO.read(file_name)
        if existing_contents == contents
          logger.record :identical, basename(file_name)
          skip_write = true
        elsif options[:force]
          logger.record :overwrite, basename(file_name)
        else
          msg = "File #{basename(file_name)} already exists. Run with --force to force overwrite."
          raise Compass::FilesystemConflict.new(msg)
        end
      else
        logger.record :create, basename(file_name)
      end
      if skip_write
        FileUtils.touch file_name
      else
        mode = "w"
        mode << "b" if binary
        open(file_name, mode) do |file|
          file.write(contents)
        end
      end
    end

    # Compile one Sass file
    def compile(sass_filename, css_filename, options)
      if options[:force] || Sass::Plugin.exact_stylesheet_needs_update?(css_filename, sass_filename)
        logger.record :compile, basename(sass_filename) unless options[:quiet]
        engine = ::Sass::Engine.new(open(sass_filename).read,
                                    :filename => sass_filename,
                                    :line_comments => options[:line_comments],
                                    :style => options[:style],
                                    :css_filename => css_filename,
                                    :load_paths => options[:load_paths],
                                    :cache_location => options[:cache_location])
        css_content = engine.render
        write_file(css_filename, css_content, options.merge(:force => true))
      else
        logger.record :unchanged, basename(sass_filename) unless options[:quiet]
      end
    end

    def remove(file_name)
      if File.exists?(file_name)
        File.unlink file_name
        logger.record :remove, basename(file_name)
      end
    end

    def basename(file)
      relativize(file) {|f| File.basename(file)}
    end

    def relativize(path)
      if path.index(working_path+File::SEPARATOR) == 0
        path[(working_path+File::SEPARATOR).length..-1]
      elsif block_given?
        yield path
      else
        path
      end
    end

    # Write paths like we're on unix and then fix it
    def separate(path)
      path.gsub(%r{/}, File::SEPARATOR)
    end

    # Removes the trailing separator, if any, from a path.
    def strip_trailing_separator(path)
      (path[-1..-1] == File::SEPARATOR) ? path[0..-2] : path
    end

  end
end
