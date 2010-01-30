module Compass
  class Compiler

    include Actions

    attr_accessor :working_path, :from, :to, :options

    def initialize(working_path, from, to, options)
      self.working_path = working_path
      self.from, self.to = from, to
      self.logger = options.delete(:logger)
      self.options = options
      self.options[:cache_location] ||= determine_cache_location
    end

    def determine_cache_location
      Compass.configuration.cache_path || Sass::Plugin.options[:cache_location] || File.join(working_path, ".sass-cache")
    end

    def sass_files(options = {})
      exclude_partials = options.fetch(:exclude_partials, true)
      @sass_files = self.options[:sass_files] || Dir.glob(separate("#{from}/**/#{'[^_]' if exclude_partials}*.s[ac]ss"))
    end

    def stylesheet_name(sass_file)
      sass_file[("#{from}/".length)..-6]
    end

    def css_files
      @css_files ||= sass_files.map{|sass_file| corresponding_css_file(sass_file)}
    end

    def corresponding_css_file(sass_file)
      "#{to}/#{stylesheet_name(sass_file)}.css"
    end

    def target_directories
      css_files.map{|css_file| File.dirname(css_file)}.uniq.sort.sort_by{|d| d.length }
    end

    # Returns the sass file that needs to be compiled, if any.
    def out_of_date?
      Compass.configure_sass_plugin! unless Compass.sass_plugin_configured?
      sass_files.zip(css_files).each do |sass_filename, css_filename|
        return sass_filename if Sass::Plugin.send(:exact_stylesheet_needs_update?, css_filename, sass_filename)
      end
      false
    end

    # Determines if the configuration file is newer than any css file
    def new_config?
      config_file = Compass.detect_configuration_file
      return false unless config_file
      config_mtime = File.mtime(config_file)
      css_files.each do |css_filename|
        return config_file if File.exists?(css_filename) && config_mtime > File.mtime(css_filename)
      end
      nil
    end

    def run
      if new_config?
        # Wipe out the cache and force compilation if the configuration has changed.
        FileUtils.rm_rf options[:cache_location]
        options[:force] = true
      end

      # We use the Sass::Plugin to check dependencies so we have configure it.
      Compass.configure_sass_plugin! unless Compass.sass_plugin_configured?

      # Make sure the target directories exist
      target_directories.each {|dir| directory dir}

      # Compile each sass file.
      sass_files.zip(css_files).each do |sass_filename, css_filename|
        begin
          compile_if_required sass_filename, css_filename
        rescue Sass::SyntaxError => e
          handle_exception(sass_filename, css_filename, e)
        end
      end
    end

    def compile_if_required(sass_filename, css_filename)
      if should_compile?(sass_filename, css_filename)
        compile sass_filename, css_filename
      else
        logger.record :unchanged, basename(sass_filename) unless options[:quiet]
      end
    end

    # Compile one Sass file
    def compile(sass_filename, css_filename)
      logger.record :compile, basename(sass_filename) unless options[:quiet]
      css_content = logger.red do
        engine(sass_filename, css_filename).render
      end
      write_file(css_filename, css_content, options.merge(:force => true))
    end

    def should_compile?(sass_filename, css_filename)
      options[:force] || Sass::Plugin.send(:exact_stylesheet_needs_update?, css_filename, sass_filename)
    end

    # A sass engine for compiling a single file.
    def engine(sass_filename, css_filename)
      syntax = (sass_filename =~ /\.(s[ac]ss)$/) && $1.to_sym || :sass
      opts = options.merge :filename => sass_filename, :css_filename => css_filename, :syntax => syntax
      Sass::Engine.new(open(sass_filename).read, opts)
    end

    # Place the syntax error into the target css file,
    # formatted to display in the browser (in development mode)
    # if there's an error.
    def handle_exception(sass_filename, css_filename, e)
      logger.record :error, basename(sass_filename), "(Line #{e.sass_line}: #{e.message})"
      write_file css_filename, error_contents(e, sass_filename), options.merge(:force => true)
    end

    # Haml refactored this logic in 2.3, this is backwards compatibility for either one
    def error_contents(e, sass_filename)
      if Sass::SyntaxError.respond_to?(:exception_to_css)
        e.sass_template = sass_filename
        Sass::SyntaxError.exception_to_css(e, :full_exception => show_full_exception?)
      else
        Sass::Plugin.options[:full_exception] ||= show_full_exception?
        Sass::Plugin.send(:exception_string, e)
      end
    end

    # We don't want to show the full exception in production environments.
    def show_full_exception?
      Compass.configuration.environment == :development
    end

  end
end
