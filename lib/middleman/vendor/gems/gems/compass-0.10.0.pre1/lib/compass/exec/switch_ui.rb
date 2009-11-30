require 'compass/exec/global_options_parser'
require 'compass/exec/project_options_parser'

module Compass::Exec
  class SwitchUI
    include GlobalOptionsParser
    include ProjectOptionsParser
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
          ::Compass::Exec::Helpers.report_error(e, @options)
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
                                         '  Dimension is given as <column_width>+<gutter_width>x<height>.',
                                         '  Defaults to 30+10x20. Height is optional.') do |dimensions|
        self.options[:grid_dimensions] = dimensions || "30+10"
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

      opts.on('--rails', "Sets the app type to a rails project (same as --app rails).") do
        self.options[:project_type] = :rails
      end

      opts.on('--app APP_TYPE', 'Specify the kind of application to integrate with.') do |project_type|
        self.options[:project_type] = project_type.to_sym
      end

      opts.separator ''
      opts.separator 'Configuration Options:'

      set_project_options(opts)

      opts.separator ''
      opts.separator 'General Options:'

      set_global_options(opts)

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
