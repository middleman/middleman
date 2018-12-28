require 'middleman-core/application'

# CLI Module
module Middleman::Cli
  # The CLI Build class
  class Build < Thor::Group
    include Thor::Actions

    check_unknown_options!

    class_option :environment,
                 aliases: '-e',
                 default: ENV['MM_ENV'] || ENV['RACK_ENV'] || :production
    class_option :clean,
                 type: :boolean,
                 default: true,
                 desc: 'Remove orphaned files from build (--no-clean to disable)'
    class_option :parallel,
                 type: :boolean,
                 default: true,
                 desc: 'Output files in parallel (--no-parallel to disable)'
    class_option :glob,
                 type: :string,
                 aliases: '-g',
                 default: nil,
                 desc: 'Build a subset of the project'
    class_option :verbose,
                 type: :boolean,
                 default: false,
                 desc: 'Print debug messages'
    class_option :instrument,
                 type: :boolean,
                 default: false,
                 desc: 'Print instrument messages'
    class_option :profile,
                 type: :boolean,
                 default: false,
                 desc: 'Generate profiling report for the build'
    class_option :dry_run,
                 type: :boolean,
                 default: false,
                 desc: 'Skip writing output files'
    class_option :track_dependencies,
                 type: :boolean,
                 default: false,
                 desc: 'Track file dependencies'
    class_option :only_changed,
                 type: :boolean,
                 default: false,
                 desc: 'Only build changed files'
    class_option :missing_and_changed,
                 type: :boolean,
                 default: false,
                 desc: 'Only build changed files or files missing from build folder'

    Middleman::Cli.import_config(self)

    # Core build Thor command
    # @return [void]
    def build
      root = ENV['MM_ROOT'] || Dir.pwd

      raise Thor::Error, 'Error: Could not find a Middleman project config, perhaps you are in the wrong folder?' unless File.exist?(File.join(root, 'config.rb'))

      require 'middleman-core'
      require 'middleman-core/logger'
      require 'middleman-core/builder'
      require 'fileutils'

      verbose = options['verbose'] ? 0 : 1
      instrument = options['instrument']

      builder = nil
      cli_options = options

      ::Middleman::Logger.singleton(verbose, instrument)

      ::Middleman::Util.instrument 'builder.setup' do
        missing_and_changed = !options['only_changed'] && options['missing_and_changed']
        should_track_dependencies = options['only_changed'] || missing_and_changed || options['track_dependencies']

        @app = ::Middleman::Application.new do
          config[:mode] = :build
          config[:show_exceptions] = false
          config[:cli_options] = cli_options.each_with_object({}) do |(k, v), sum|
            sum[k] = v
          end
          config[:track_data_access] = should_track_dependencies
        end

        builder = Middleman::Builder.new(@app,
                                         glob: options['glob'],
                                         dry_run: options['dry_run'],
                                         clean: options['clean'],
                                         parallel: options['parallel'],
                                         only_changed: options['only_changed'],
                                         missing_and_changed: missing_and_changed,
                                         track_dependencies: should_track_dependencies)
        builder.thor = self
        builder.on_build_event(&method(:on_event))
      end

      ::Middleman::Util.instrument 'builder.run' do
        if builder.run!
          clean_directories! if options['clean']
          puts 'Project built successfully.'
        else
          msg = 'There were errors during this build'
          msg << ', re-run with `middleman build --verbose` to see the full exception.' unless options['verbose']
          shell.say msg, :red

          exit(1)
        end
      end
    end

    protected

    # Handles incoming events from the builder.
    # @param [Symbol] event_type The type of event.
    # @param [String] contents The event contents.
    # @param [String] extra The extra information.
    # @return [void]
    def on_event(event_type, target, extra = nil)
      case event_type
      when :error
        say_status :error, target, :red
        shell.say extra, :red if options['verbose']
      when :deleted
        say_status :remove, target, :green
      when :created
        say_status :create, target, :green
      when :identical
        say_status :identical, target, :blue
      when :skipped
        say_status :skipped, target, :blue
      when :updated
        say_status :updated, target, :yellow
      else
        say_status event_type, extra, :blue
      end
    end

    # Find empty directories in the build folder and remove them.
    # @return [Boolean]
    def clean_directories!
      all_build_files = File.join(@app.config[:build_dir], '**', '*')

      empty_directories = Dir[all_build_files].select do |d|
        File.directory?(d)
      end

      empty_directories.each do |d|
        remove_file d, force: true if Pathname(d).children.empty?
      end
    end

    # Add to CLI
    Base.register(self, 'build', 'build [options]', 'Builds the static site for deployment')

    # Map "b" to "build"
    Base.map('b' => 'build')
  end
end
