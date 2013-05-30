require "middleman-core"
require "middleman-core/builder"
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
      :default => true,
      :desc    => 'Remove orphaned files from build (--no-clean to disable)'
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

      @debugging = Middleman::Cli::Base.respond_to?(:debugging) && Middleman::Cli::Base.debugging
      @had_errors = false

      is_verbose = options["verbose"] ? 0 : 1
      is_instrumenting = options["instrument"]
      @app = ::Middleman::Application.server.inst do
        config[:environment] = :build
        logger(is_verbose, is_instrumenting)
      end

      mb = Middleman::Builder.new(@app, options)

      mb.on_file_output(&method(:on_file))
      mb.on_file_error(&method(:on_error))

      queue_current_paths if cleaning?

      mb.run!

      clean! if cleaning?

      @app.run_hook :after_build, self

      if @had_errors && !@debugging
        msg = "There were errors during this build"
        unless options["verbose"]
          msg << ", re-run with `middleman build --verbose` to see the full exception."
        end
        self.shell.say msg, :red
      end

      exit(1) if @had_errors
    end

    # Static methods
    class << self
      def exit_on_failure?
        true
      end
    end

    no_tasks {
      def on_file(output_file, source, binary)
        if binary
          if !File.exists?(output_file)
            say_status :create, output_file, :green
          elsif FileUtils.compare_file(source, output_file)
            say_status :identical, output_file, :blue
            return output_file
          else
            say_status :update, output_file, :yellow
          end

          FileUtils.mkdir_p(File.dirname(output_file))
          FileUtils.cp(source, output_file)
        else
          create_file(output_file, source)
        end

        if cleaning?
          pn = Pathname(output_file)
          @cleaning_queue.delete(pn.realpath) if pn.exist?
        end
      end

      def on_error(file_name, response, e)
        @had_errors = true
        e ||= Thor::Error.new(response)

        say_status :error, file_name, :red
        if self.debugging
          raise e
          exit(1)
        elsif options["verbose"]
          self.shell.say response, :red
        end
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
        return unless File.exist?(@app.build_dir)

        paths = ::Middleman::Util.all_files_under(@app.build_dir)
        @cleaning_queue += paths.select do |path|
          path.to_s !~ /\/\./ || path.to_s =~ /\.(htaccess|htpasswd)/
        end
      end

      def cleaning?
        options["clean"]
      end

      # Remove files which were not built in this cycle
      # @return [void]
      def clean!
        files       = @cleaning_queue.select { |q| q.file? }
        directories = @cleaning_queue.select { |q| q.directory? }

        files.each do |f|
          remove_file f, :force => true
        end

        # Remove empty directories
        directories = directories.sort_by {|d| d.to_s.length }.reverse!

        directories.each do |d|
          base.remove_file d, :force => true if directory_empty? d
        end
      end
    }
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
