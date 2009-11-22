require File.join(Compass.lib_directory, 'compass', 'dependencies')
require 'optparse'
require File.join(Compass.lib_directory, 'compass', 'logger')
require File.join(Compass.lib_directory, 'compass', 'errors')
require File.join(Compass.lib_directory, 'compass', 'actions')

module Compass
  module Exec

    def report_error(e, options)
      $stderr.puts "#{e.class} on line #{get_line e} of #{get_file e}: #{e.message}"
      if options[:trace]
        e.backtrace[1..-1].each { |t| $stderr.puts "  #{t}" }
      else
        $stderr.puts "Run with --trace to see the full backtrace"
      end
    end

    def get_file(exception)
      exception.backtrace[0].split(/:/, 2)[0]
    end

    def get_line(exception)
      exception.backtrace[0].scan(/:(\d+)/)[0]
    end
    module_function :report_error, :get_file, :get_line

    class Compass
      
      attr_accessor :args, :options, :opts

      def initialize(args)
        self.args = args
        self.options = {}
        parse!
      end

      def run!
        begin
          perform!
        rescue Exception => e
          raise e if e.is_a? SystemExit
          if e.is_a?(::Compass::Error) || e.is_a?(OptionParser::ParseError)
            $stderr.puts e.message
          else
            ::Compass::Exec.report_error(e, @options)
          end
          return 1
        end
        return 0
      end
      
      protected
      
      def perform!
        if options[:command]
          do_command(options[:command])
        else
          puts self.opts
        end
      end
      
      def parse!
        self.opts = OptionParser.new(&method(:set_opts))
        self.opts.parse!(self.args)    
        if self.args.size > 0
          self.options[:project_name] = trim_trailing_separator(self.args.shift)
        end
        self.options[:command] ||= self.options[:project_name] ? :create_project : :update_project
        self.options[:framework] ||= :compass
        self.options[:project_type] ||= :stand_alone
      end

      def trim_trailing_separator(path)
        path[-1..-1] == File::SEPARATOR ? path[0..-2] : path
      end

      def set_opts(opts)
        opts.banner = <<END
Usage: compass [options] [project]

Description:
  The compass command line tool will help you create and manage the stylesheets for your project.
  
  To get started on a stand-alone project based on blueprint:

    compass -f blueprint my_compass_project

  When you change any sass files, you must recompile your project using --update or --watch.
END
        opts.separator ''
        opts.separator 'Mode Options(only specify one):'

        opts.on('-i', '--install', :NONE, "Create a new compass project.",
                                          "  The default mode when a project is provided.") do
          self.options[:command] = :create_project
        end

        opts.on('-u', '--update', :NONE, 'Update the current project.',
                                         '  This is the default when no project is provided.') do
          self.options[:command] = :update_project
        end

        opts.on('-w', '--watch', :NONE, 'Monitor the current project for changes and update') do
          self.options[:command] = :watch_project
          self.options[:quiet] = true
        end

        opts.on('-p', '--pattern PATTERN', 'Stamp out a pattern into the current project.',
                                           '  Must be used with -f.') do |pattern|
          self.options[:command] = :stamp_pattern
          self.options[:pattern] = pattern
        end

        opts.on('--write-configuration', "Write the current configuration to the configuration file.") do
          self.options[:command] = :write_configuration
        end

        opts.on('--list-frameworks', "List compass frameworks available to use.") do
          self.options[:command] = :list_frameworks
        end

        opts.on('--validate', :NONE, 'Validate your project\'s compiled css. Requires Java.') do
          self.options[:command] = :validate_project
        end

        opts.on('--grid-img [DIMENSIONS]', 'Generate a background image to test grid alignment.',
                                           '  Dimension is given as <column_width>+<gutter_width>.',
                                           '  Defaults to 30+10.') do |dimensions|
          self.options[:grid_dimensions] = dimensions || "30+10"
          unless self.options[:grid_dimensions] =~ /^\d+\+\d+$/
            puts "Please enter your dimensions as <column_width>+<gutter_width>. E.g. 20+5 or 30+10."
            exit
          end
          self.options[:command] = :generate_grid_background
        end

        opts.separator ''
        opts.separator 'Install/Pattern Options:'

        opts.on('-f FRAMEWORK', '--framework FRAMEWORK', 'Use the specified framework. Only one may be specified.') do |framework|
          self.options[:framework] = framework
        end

        opts.on('-n', '--pattern-name NAME', 'The name to use when stamping a pattern.',
                                             '  Must be used in combination with -p.') do |name|
          self.options[:pattern_name] = name
        end

        opts.on('--rails', "Sets the project type to a rails project.") do
          self.options[:project_type] = :rails
        end

        opts.separator ''
        opts.separator 'Configuration Options:'

        opts.on('-c', '--config CONFIG_FILE', 'Specify the location of the configuration file explicitly.') do |configuration_file|
          self.options[:configuration_file] = configuration_file
        end

        opts.on('--sass-dir SRC_DIR', "The source directory where you keep your sass stylesheets.") do |sass_dir|
          self.options[:sass_dir] = sass_dir
        end

        opts.on('--css-dir CSS_DIR', "The target directory where you keep your css stylesheets.") do |css_dir|
          self.options[:css_dir] = css_dir
        end

        opts.on('--images-dir IMAGES_DIR', "The directory where you keep your images.") do |images_dir|
          self.options[:images_dir] = images_dir
        end

        opts.on('--javascripts-dir JS_DIR', "The directory where you keep your javascripts.") do |javascripts_dir|
          self.options[:javascripts_dir] = javascripts_dir
        end

        opts.on('-e ENV', '--environment ENV', [:development, :production], 'Use sensible defaults for your current environment.',
                '  One of: development, production (default)') do |env|
          self.options[:environment] = env
        end

        opts.on('-s STYLE', '--output-style STYLE', [:nested, :expanded, :compact, :compressed], 'Select a CSS output mode.',
                 '  One of: nested, expanded, compact, compressed') do |style|
          self.options[:output_style] = style
        end

        opts.on('--relative-assets', :NONE, 'Make compass asset helpers generate relative urls to assets.') do
          self.options[:relative_assets] = true
        end

        opts.separator ''
        opts.separator 'General Options:'

        opts.on('-r LIBRARY', '--require LIBRARY', "Require the given ruby LIBRARY before running commands.",
                                                   "  This is used to access compass plugins without having a",
                                                   "  project configuration file.") do |library|
          ::Compass.configuration.require library
        end
        
        opts.on('-q', '--quiet', :NONE, 'Quiet mode.') do
          self.options[:quiet] = true
        end

        opts.on('--dry-run', :NONE, 'Dry Run. Tells you what it plans to do.') do
          self.options[:dry_run] = true
        end

        opts.on('--trace', :NONE, 'Show a full stacktrace on error') do
          self.options[:trace] = true
        end
        
        opts.on('--force', :NONE, 'Force. Allows some failing commands to succeed instead.') do
          self.options[:force] = true
        end

        opts.on('--imports', :NONE, 'Emit an imports suitable for passing to the sass command-line.',
                                    '  Example: sass `compass --imports`',
                                    '  Note: Compass\'s Sass extensions will not be available.') do
          print ::Compass::Frameworks::ALL.map{|f| "-I #{f.stylesheets_directory}"}.join(' ')
          exit
        end

        opts.on('--install-dir', :NONE, 'Emit the location where compass is installed.') do
          puts ::Compass.base_directory
          exit
        end

        opts.on_tail("-?", "-h", "--help", "Show this message") do
          puts opts
          exit
        end

        opts.on_tail("-v", "--version", "Print version") do
          self.options[:command] = :print_version
        end

      end
      
      def do_command(command)
        command_class_name = command.to_s.split(/_/).map{|p| p.capitalize}.join('')
        command_class = eval("::Compass::Commands::#{command_class_name}")
        command_class.new(Dir.getwd, options).execute
      end

    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), 'commands', "*.rb")).each do |file|
  require file
end
