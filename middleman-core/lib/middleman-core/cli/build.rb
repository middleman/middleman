require "middleman-core"
require "fileutils"

# CLI Module
module Middleman::Cli

  # The CLI Build class
  class Build < Thor
    include Thor::Actions

    attr_reader :debugging

    check_unknown_options!

    namespace :build

    desc "build [options]", "Builds the static site for deployment"
    method_option :clean,
      :type    => :boolean,
      :aliases => "-c",
      :default => false,
      :desc    => 'Removes orphaned files or directories from build'
    method_option :glob,
      :type    => :string,
      :aliases => "-g",
      :default => nil,
      :desc    => 'Build a subset of the project'
    method_option :verbose,
      :type    => :boolean,
      :default => false,
      :desc    => 'Print debug messages'
    method_option :instrument,
      :type    => :string,
      :default => false,
      :desc    => 'Print instrument messages'
    method_option :profile,
      :type    => :boolean,
      :default => false,
      :desc    => 'Generate profiling report for the build'

    # Core build Thor command
    # @return [void]
    def build
      if !ENV["MM_ROOT"]
        raise Thor::Error, "Error: Could not find a Middleman project config, perhaps you are in the wrong folder?"
      end

      # Use Rack::Test for inspecting a running server for output
      require "rack"
      require "rack/test"

      require 'find'

      @debugging = Middleman::Cli::Base.respond_to?(:debugging) && Middleman::Cli::Base.debugging
      @had_errors = false

      self.class.shared_instance(options["verbose"], options["instrument"])

      self.class.shared_rack

      opts = {}
      opts[:glob]  = options["glob"]  if options.has_key?("glob")
      opts[:clean] = options["clean"] if options.has_key?("clean")

      action GlobAction.new(self, opts)

      if @had_errors && !@debugging
        cmd = "middleman build --verbose"
        cmd = "bundle exec '#{cmd}'" if defined?(Bundler)
        self.shell.say "There were errors during this build, re-run with `#{cmd}` to see the full exception."
      end

      exit(1) if @had_errors

      self.class.shared_instance.run_hook :after_build, self
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
          set :environment, :build
          logger(verbose ? 0 : 1, instrument)
        end
      end

      # Middleman::Application class singleton
      #
      # @return [Middleman::Application]
      def shared_server
        @_shared_server ||= shared_instance.class
      end

      # Rack::Test::Session singleton
      #
      # @return [Rack::Test::Session]
      def shared_rack
        @_shared_rack ||= ::Rack::Test::Session.new(shared_server.to_rack_app)
      end

      # Set the root path to the Middleman::Application's root
      def source_root
        shared_instance.root
      end
    end

    no_tasks {
      # Render a resource to a file.
      #
      # @param [Middleman::Sitemap::Resource] resource
      # @return [String] The full path of the file that was written
      def render_to_file(resource)
        build_dir = self.class.shared_instance.build_dir
        output_file = File.join(build_dir, resource.destination_path)

        if resource.binary?
          if !File.exists?(output_file)
            say_status :create, output_file, :green
          elsif FileUtils.compare_file(resource.source_file, output_file)
            say_status :identical, output_file, :blue
            return output_file
          else
            say_status :update, output_file, :yellow
          end

          FileUtils.mkdir_p(File.dirname(output_file))
          FileUtils.cp(resource.source_file, output_file)
        else
          begin
            response = self.class.shared_rack.get(URI.escape(resource.destination_path))

            if response.status == 200
              create_file(output_file, response.body)
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
        @had_errors = true

        say_status :error, file_name, :red
        if self.debugging
          raise e
          exit(1)
        elsif options["verbose"]
          self.shell.error(response)
        end
      end
    }
  end

  # A Thor Action, modular code, which does the majority of the work.
  class GlobAction < ::Thor::Actions::EmptyDirectory
    attr_reader :source
    attr_reader :logger

    # Setup the action
    #
    # @param [Middleman::Cli::Build] base
    # @param [Hash] config
    def initialize(base, config={})
      @app         = base.class.shared_instance
      source       = @app.source
      @destination = @app.build_dir

      @source = File.expand_path(base.find_in_source_paths(source.to_s))

      @logger = Middleman::Cli::Build.shared_instance.logger

      super(base, @destination, config)
    end

    # Execute the action
    # @return [void]
    def invoke!
      queue_current_paths if cleaning?
      execute!
      clean! if cleaning?
    end

  protected

    # Remove files which were not built in this cycle
    # @return [void]
    def clean!
      files       = @cleaning_queue.select { |q| q.file? }
      directories = @cleaning_queue.select { |q| q.directory? }

      files.each do |f|
        base.remove_file f, :force => true
      end

      directories = directories.sort_by {|d| d.to_s.length }.reverse!

      directories.each do |d|
        base.remove_file d, :force => true if directory_empty? d
      end
    end

    # Whether we should clean the build
    # @return [Boolean]
    def cleaning?
      @config.has_key?(:clean) && @config[:clean]
    end

    # Whether the given directory is empty
    # @param [String] directory
    # @return [Boolean]
    def directory_empty?(directory)
      directory.children.empty?
    end

    # Get a list of all the paths in the destination folder and save them
    # for comparison against the files we build in this cycle
    # @return [void]
    def queue_current_paths
      @cleaning_queue = []
      return unless File.exist?(@destination)

      paths = ::Middleman::Util.all_files_under(@destination)
      @cleaning_queue += paths.select do |path|
        path.to_s !~ /\/\./ || path.to_s =~ /\.(htaccess|htpasswd)/
      end
    end

    # Actually build the app
    # @return [void]
    def execute!
      # Sort order, images, fonts, js/css and finally everything else.
      sort_order = %w(.png .jpeg .jpg .gif .bmp .svg .svgz .ico .woff .otf .ttf .eot .js .css)

      # Pre-request CSS to give Compass a chance to build sprites
      logger.debug "== Prerendering CSS"

      @app.sitemap.resources.select do |resource|
        resource.ext == ".css"
      end.each do |resource|
        Middleman::Cli::Build.shared_rack.get(URI.escape(resource.destination_path))
      end

      logger.debug "== Checking for Compass sprites"

      # Double-check for compass sprites
      @app.files.find_new_files((Pathname(@app.source_dir) + @app.images_dir).relative_path_from(@app.root_path))
      @app.sitemap.ensure_resource_list_updated!

      # Sort paths to be built by the above order. This is primarily so Compass can
      # find files in the build folder when it needs to generate sprites for the
      # css files

      logger.debug "== Building files"

      resources = @app.sitemap.resources.sort_by do |r|
        sort_order.index(r.ext) || 100
      end

      # Loop over all the paths and build them.
      resources.each do |resource|
        next if @config[:glob] && !File.fnmatch(@config[:glob], resource.destination_path)

        output_path = base.render_to_file(resource)

        if cleaning?
          pn = Pathname(output_path)
          @cleaning_queue.delete(pn.realpath) if pn.exist?
        end
      end

      ::Middleman::Profiling.report("build")
    end
  end

  # Alias "b" to "build"
  Base.map({ "b" => "build" })
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
