require 'fileutils'
require 'set'

# CLI Module
module Middleman::Cli
  # Alias "b" to "build"
  Base.map('b' => 'build')

  # The CLI Build class
  class Build < Thor
    include Thor::Actions

    attr_reader :debugging
    attr_accessor :had_errors

    check_unknown_options!

    namespace :build

    desc 'build [options]', 'Builds the static site for deployment'
    method_option :clean,
                  type: :boolean,
                  default: true,
                  desc: 'Remove orphaned files from build (--no-clean to disable)'
    method_option :glob,
                  type: :string,
                  aliases: '-g',
                  default: nil,
                  desc: 'Build a subset of the project'
    method_option :verbose,
                  type: :boolean,
                  default: false,
                  desc: 'Print debug messages'
    method_option :instrument,
                  type: :string,
                  default: false,
                  desc: 'Print instrument messages'
    method_option :profile,
                  type: :boolean,
                  default: false,
                  desc: 'Generate profiling report for the build'

    # Core build Thor command
    # @return [void]
    def build
      unless ENV['MM_ROOT']
        raise Thor::Error, 'Error: Could not find a Middleman project config, perhaps you are in the wrong folder?'
      end

      require 'middleman-core'
      require 'middleman-core/logger'

      # Use Rack::Test for inspecting a running server for output
      require 'rack'
      require 'rack/test'

      require 'find'

      @debugging = Middleman::Cli::Base.respond_to?(:debugging) && Middleman::Cli::Base.debugging
      self.had_errors = false

      self.class.shared_instance(options['verbose'], options['instrument'])

      opts = {}
      opts[:glob]  = options['glob'] if options.key?('glob')
      opts[:clean] = options['clean']

      self.class.shared_instance.run_hook :before_build, self

      action BuildAction.new(self, opts)

      self.class.shared_instance.run_hook :after_build, self

      if had_errors && !debugging
        msg = 'There were errors during this build'
        unless options['verbose']
          msg << ', re-run with `middleman build --verbose` to see the full exception.'
        end
        shell.say msg, :red
      end

      exit(1) if had_errors
    end

    # Static methods
    class << self
      def exit_on_failure?
        true
      end

      # Middleman::Application singleton
      #
      # @return [Middleman::Application]
      def shared_instance(verbose=false, instrument=false)
        @_shared_instance ||= ::Middleman::Application.server.inst do
          config[:environment] = :build
          ::Middleman::Logger.singleton(verbose ? 0 : 1, instrument)
        end
      end
    end
  end

  # A Thor Action, modular code, which does the majority of the work.
  class BuildAction < ::Thor::Actions::EmptyDirectory
    attr_reader :source
    attr_reader :logger

    # Setup the action
    #
    # @param [Middleman::Cli::Build] base
    # @param [Hash] config
    def initialize(base, config={})
      @app        = base.class.shared_instance
      @source_dir = Pathname(@app.source_dir)
      @build_dir  = Pathname(@app.build_dir)
      @to_clean   = Set.new

      @logger = @app.logger
      @rack = ::Rack::Test::Session.new(@app.class.to_rack_app)

      super(base, @build_dir, config)
    end

    # Execute the action
    # @return [void]
    def invoke!
      queue_current_paths if should_clean?
      execute!
      clean! if should_clean?
    end

    protected

    # Remove files which were not built in this cycle
    # @return [void]
    def clean!
      @to_clean.each do |f|
        base.remove_file f, force: true
      end

      ::Middleman::Util.glob_directory(@build_dir.join('**', '*'))
        .select { |d| File.directory?(d) }
        .each do |d|
        base.remove_file d, force: true if directory_empty? d
      end
    end

    # Whether we should clean the build
    # @return [Boolean]
    def should_clean?
      @config[:clean]
    end

    # Whether the given directory is empty
    # @param [String, Pathname] directory
    # @return [Boolean]
    def directory_empty?(directory)
      Pathname(directory).children.empty?
    end

    # Get a list of all the file paths in the destination folder and save them
    # for comparison against the files we build in this cycle
    # @return [void]
    def queue_current_paths
      return unless File.exist?(@build_dir)

      paths = ::Middleman::Util.all_files_under(@build_dir).map(&:realpath).select(&:file?)

      @to_clean += paths.select do |path|
        path.to_s !~ /\/\./ || path.to_s =~ /\.(htaccess|htpasswd)/
      end

      return unless RUBY_PLATFORM =~ /darwin/

      # handle UTF-8-MAC filename on MacOS
      @to_clean = @to_clean.map { |path| path.to_s.encode('UTF-8', 'UTF-8-MAC') }
    end

    # Actually build the app
    # @return [void]
    def execute!
      # Sort order, images, fonts, js/css and finally everything else.
      sort_order = %w(.png .jpeg .jpg .gif .bmp .svg .svgz .ico .webp .woff .woff2 .otf .ttf .eot .js .css)

      # Pre-request CSS to give Compass a chance to build sprites
      logger.debug '== Prerendering CSS'

      @app.sitemap.resources.select do |resource|
        resource.ext == '.css'
      end.each(&method(:build_resource))

      logger.debug '== Checking for Compass sprites'

      # Double-check for compass sprites
      @app.files.find_new_files((@source_dir + @app.images_dir).relative_path_from(@app.root_path))
      @app.sitemap.ensure_resource_list_updated!

      # Sort paths to be built by the above order. This is primarily so Compass can
      # find files in the build folder when it needs to generate sprites for the
      # css files

      logger.debug '== Building files'

      resources = @app.sitemap.resources.sort_by do |r|
        sort_order.index(r.ext) || 100
      end

      if @build_dir.expand_path.relative_path_from(@source_dir).to_s =~ /\A[.\/]+\Z/
        raise ":build_dir (#{@build_dir}) cannot be a parent of :source_dir (#{@source_dir})"
      end

      # Loop over all the paths and build them.
      resources.reject do |resource|
        resource.ext == '.css'
      end.each(&method(:build_resource))

      ::Middleman::Profiling.report('build')
    end

    def build_resource(resource)
      return if @config[:glob] && !File.fnmatch(@config[:glob], resource.destination_path)

      output_path = render_to_file(resource)

      return unless should_clean? && output_path.exist?

      if RUBY_PLATFORM =~ /darwin/
        # handle UTF-8-MAC filename on MacOS

        @to_clean.delete(output_path.realpath.to_s.encode('UTF-8', 'UTF-8-MAC'))
      else
        @to_clean.delete(output_path.realpath)
      end
    end

    # Render a resource to a file.
    #
    # @param [Middleman::Sitemap::Resource] resource
    # @return [Pathname] The full path of the file that was written
    def render_to_file(resource)
      output_file = @build_dir + resource.destination_path.gsub('%20', ' ')

      if resource.binary?
        if !output_file.exist?
          base.say_status :create, output_file, :green
        elsif FileUtils.compare_file(resource.source_file, output_file)
          base.say_status :identical, output_file, :blue
          return output_file
        else
          base.say_status :update, output_file, :yellow
        end

        output_file.dirname.mkpath
        FileUtils.cp(resource.source_file, output_file)
      else
        begin
          response = @rack.get(URI.escape(resource.request_path))

          if response.status == 200
            base.create_file(output_file, binary_encode(response.body))
          else
            handle_error(output_file, response.body)
          end
        rescue => e
          handle_error(output_file, "#{e}\n#{e.backtrace.join("\n")}", e)
        end
      end

      output_file
    end

    def handle_error(file_name, response, e=Thor::Error.new(response))
      base.had_errors = true

      base.say_status :error, file_name, :red
      if base.debugging
        raise e
      elsif base.options['verbose']
        base.shell.say response, :red
      end
    end

    def binary_encode(string)
      string.force_encoding('ascii-8bit') if string.respond_to?(:force_encoding)
      string
    end
  end
end

# Quiet down create file
class ::Thor::Actions::CreateFile
  def on_conflict_behavior(&block)
    if identical?
      say_status :identical, :blue
    else
      say_status :update, :yellow
      block.call unless pretend?
    end
  end
end
