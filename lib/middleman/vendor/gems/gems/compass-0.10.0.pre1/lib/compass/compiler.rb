module Compass
  class Compiler

    include Actions

    attr_accessor :working_path, :from, :to, :options

    def initialize(working_path, from, to, options)
      self.working_path = working_path
      self.from, self.to = from, to
      self.logger = options.delete(:logger)
      self.options = options
      self.options[:cache_location] ||= File.join(from, ".sass-cache")
    end

    def sass_files(options = {})
      exclude_partials = options.fetch(:exclude_partials, true)
      @sass_files || Dir.glob(separate("#{from}/**/#{'[^_]' if exclude_partials}*.sass"))
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

    def out_of_date?
      Compass.configure_sass_plugin! unless Compass.sass_plugin_configured?
      sass_files.zip(css_files).each do |sass_filename, css_filename|
        return sass_filename if Sass::Plugin.exact_stylesheet_needs_update?(css_filename, sass_filename)
      end
      false
    end

    def run
      Compass.configure_sass_plugin! unless Compass.sass_plugin_configured?
      target_directories.each do |dir|
        directory dir
      end
      sass_files.zip(css_files).each do |sass_filename, css_filename|
        begin
          compile sass_filename, css_filename, options
        rescue Sass::SyntaxError => e
          full_exception = Compass.configuration.environment == :development
          logger.record :error, basename(sass_filename), "(Line #{e.sass_line}: #{e.message})"
          write_file(css_filename,
            Sass::SyntaxError.exception_to_css(e, :full_exception => full_exception),
            options.merge(:force => true))
        end
      end
    end
  end
end
