require 'pathname'
require 'fileutils'
require 'tempfile'
require 'parallel'
require 'middleman-core/rack'
require 'middleman-core/callback_manager'
require 'middleman-core/contracts'

module Middleman
  class Builder
    extend Forwardable
    include Contracts

    # Make app & events available to `after_build` callbacks.
    attr_reader :app, :events

    # Reference to the Thor class.
    attr_accessor :thor

    # Logger comes from App.
    def_delegator :@app, :logger

    # Sort order, images, fonts, js/css and finally everything else.
    SORT_ORDER = %w(.png .jpeg .jpg .gif .bmp .svg .svgz .webp .ico .woff .woff2 .otf .ttf .eot .js .css).freeze

    # Create a new Builder instance.
    # @param [Middleman::Application] app The app to build.
    # @param [Hash] opts The builder options
    def initialize(app, opts={})
      @app = app
      @source_dir = Pathname(File.join(@app.root, @app.config[:source]))
      @build_dir = Pathname(@app.config[:build_dir])

      if @build_dir.expand_path.relative_path_from(@source_dir).to_s =~ /\A[.\/]+\Z/
        raise ":build_dir (#{@build_dir}) cannot be a parent of :source_dir (#{@source_dir})"
      end

      @glob = opts.fetch(:glob)
      @cleaning = opts.fetch(:clean)
      @parallel = opts.fetch(:parallel, true)

      rack_app = ::Middleman::Rack.new(@app).to_app
      @rack = ::Rack::MockRequest.new(rack_app)

      @callbacks = ::Middleman::CallbackManager.new
      @callbacks.install_methods!(self, [:on_build_event])
    end

    # Run the build phase.
    # @return [Boolean] Whether the build was successful.
    Contract Bool
    def run!
      @has_error = false
      @events = {}

      ::Middleman::Util.instrument 'builder.before' do
        @app.execute_callbacks(:before_build, [self])
      end

      ::Middleman::Util.instrument 'builder.queue' do
        queue_current_paths if @cleaning
      end

      ::Middleman::Util.instrument 'builder.prerender' do
        prerender_css
      end

      ::Middleman::Profiling.start

      ::Middleman::Util.instrument 'builder.output' do
        output_files
      end

      ::Middleman::Profiling.report('build')

      unless @has_error
        ::Middleman::Util.instrument 'builder.clean' do
          clean! if @cleaning
        end

        ::Middleman::Util.instrument 'builder.after' do
          @app.execute_callbacks(:after_build, [self])
        end
      end

      !@has_error
    end

    # Pre-request CSS to give Compass a chance to build sprites
    # @return [Array<Resource>] List of css resources that were output.
    Contract ResourceList
    def prerender_css
      logger.debug '== Prerendering CSS'

      css_files = ::Middleman::Util.instrument 'builder.prerender.output' do
        resources = @app.sitemap.resources.select { |resource| resource.ext == '.css' }
        output_resources(resources)
      end

      ::Middleman::Util.instrument 'builder.prerender.check-files' do
        # Double-check for compass sprites
        unless @app.files.find_new_files!.empty?
          logger.debug '== Checking for Compass sprites'
          @app.sitemap.ensure_resource_list_updated!
        end
      end

      css_files
    end

    # Find all the files we need to output and do so.
    # @return [Array<Resource>] List of resources that were output.
    Contract ResourceList
    def output_files
      logger.debug '== Building files'

      resources = @app.sitemap.resources
                      .reject { |resource| resource.ext == '.css' }
                      .sort_by { |resource| SORT_ORDER.index(resource.ext) || 100 }

      if @glob
        resources = resources.select do |resource|
          if defined?(::File::FNM_EXTGLOB)
            File.fnmatch(@glob, resource.destination_path, ::File::FNM_EXTGLOB)
          else
            File.fnmatch(@glob, resource.destination_path)
          end
        end
      end

      output_resources(resources)
    end

    Contract ResourceList => ResourceList
    def output_resources(resources)
      results = if @parallel
        ::Parallel.map(resources, &method(:output_resource))
      else
        resources.map(&method(:output_resource))
      end

      @has_error = true if results.any? { |r| r == false }

      if @cleaning && !@has_error
        results.each do |p|
          next unless p.exist?

          # handle UTF-8-MAC filename on MacOS
          cleaned_name = if RUBY_PLATFORM =~ /darwin/
            p.to_s.encode('UTF-8', 'UTF-8-MAC')
          else
            p
          end

          @to_clean.delete(Pathname(cleaned_name))
        end
      end

      resources
    end

    # Figure out the correct event mode.
    # @param [Pathname] output_file The output file path.
    # @param [String] source The source file path.
    # @return [Symbol]
    Contract Pathname, String => Symbol
    def which_mode(output_file, source)
      if !output_file.exist?
        :created
      else
        FileUtils.compare_file(source.to_s, output_file.to_s) ? :identical : :updated
      end
    end

    # Create a tempfile for a given output with contents.
    # @param [Pathname] output_file The output path.
    # @param [String] contents The file contents.
    # @return [Tempfile]
    Contract Pathname, String => Tempfile
    def write_tempfile(output_file, contents)
      file = Tempfile.new([
                            File.basename(output_file),
                            File.extname(output_file)
                          ])
      file.binmode
      file.write(contents)
      file.close
      File.chmod(0o644, file)
      file
    end

    # Actually export the file.
    # @param [Pathname] output_file The path to output to.
    # @param [String|Pathname] source The source path or contents.
    # @return [void]
    Contract Pathname, Or[String, Pathname] => Any
    def export_file!(output_file, source)
      # ::Middleman::Util.instrument "write_file", output_file: output_file do
      source = write_tempfile(output_file, source.to_s) if source.is_a? String

      method, source_path = if source.is_a? Tempfile
        [::FileUtils.method(:mv), source.path]
      else
        [::FileUtils.method(:cp), source.to_s]
      end

      mode = which_mode(output_file, source_path)

      if mode == :created || mode == :updated
        ::FileUtils.mkdir_p(output_file.dirname)
        method.call(source_path, output_file.to_s)
      end

      source.unlink if source.is_a? Tempfile

      trigger(mode, output_file)
      # end
    end

    # Try to output a resource and capture errors.
    # @param [Middleman::Sitemap::Resource] resource The resource.
    # @return [void]
    Contract IsA['Middleman::Sitemap::Resource'] => Or[Pathname, Bool]
    def output_resource(resource)
      ::Middleman::Util.instrument 'builder.output.resource', path: File.basename(resource.destination_path) do
        output_file = @build_dir + resource.destination_path.gsub('%20', ' ')

        begin
          if resource.binary?
            export_file!(output_file, resource.file_descriptor[:full_path])
          else
            response = @rack.get(::URI.escape(resource.request_path))

            # If we get a response, save it to a tempfile.
            if response.status == 200
              export_file!(output_file, binary_encode(response.body))
            else
              trigger(:error, output_file, response.body)
              return false
            end
          end
        rescue => e
          trigger(:error, output_file, "#{e}\n#{e.backtrace.join("\n")}")
          return false
        end

        output_file
      end
    end

    # Get a list of all the paths in the destination folder and save them
    # for comparison against the files we build in this cycle
    # @return [void]
    Contract Any
    def queue_current_paths
      @to_clean = []

      return unless File.exist?(@app.config[:build_dir])

      paths = ::Middleman::Util.all_files_under(@app.config[:build_dir]).map do |path|
        Pathname(path)
      end

      @to_clean = paths.select do |path|
        path.realpath.relative_path_from(@build_dir.realpath).to_s !~ /\/\./ || path.to_s =~ /\.(htaccess|htpasswd)/
      end

      # handle UTF-8-MAC filename on MacOS
      @to_clean = @to_clean.map do |path|
        if RUBY_PLATFORM =~ /darwin/
          Pathname(path.to_s.encode('UTF-8', 'UTF-8-MAC'))
        else
          Pathname(path)
        end
      end
    end

    # Remove files which were not built in this cycle
    Contract ArrayOf[Pathname]
    def clean!
      to_remove = @to_clean.reject do |f|
        app.config[:skip_build_clean].call(f.to_s)
      end

      to_remove.each do |f|
        FileUtils.rm(f)
        trigger(:deleted, f)
      end
    end

    Contract String => String
    def binary_encode(string)
      string.force_encoding('ascii-8bit') if string.respond_to?(:force_encoding)
      string
    end

    Contract Symbol, Or[String, Pathname], Maybe[String] => Any
    def trigger(event_type, target, extra=nil)
      @events[event_type] ||= []
      @events[event_type] << target

      execute_callbacks(:on_build_event, [event_type, target, extra])
    end
  end
end
