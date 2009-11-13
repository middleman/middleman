require 'logger'
require 'cucumber/cli/options'
require 'cucumber/constantize'

module Cucumber
  module Cli
    class YmlLoadError < StandardError; end
    class ProfilesNotDefinedError < YmlLoadError; end
    class ProfileNotFound < StandardError; end

    class Configuration
      include Constantize
      
      attr_reader :options, :out_stream

      def initialize(out_stream = STDOUT, error_stream = STDERR)
        @out_stream   = out_stream
        @error_stream = error_stream
        @options = Options.new(@out_stream, @error_stream, :default_profile => 'default')
      end

      def parse!(args)
        @args = args
        @options.parse!(args)
        arrange_formats
        raise("You can't use both --strict and --wip") if strict? && wip?

        return @args.replace(@options.expanded_args_without_drb) if drb?

        set_environment_variables
      end

      def verbose?
        @options[:verbose]
      end

      def strict?
        @options[:strict]
      end

      def wip?
        @options[:wip]
      end

      def guess?
        @options[:guess]
      end

      def diff_enabled?
        @options[:diff_enabled]
      end

      def drb?
        @options[:drb]
      end

      def drb_port
        @options[:drb_port].to_i if @options[:drb_port]
      end
      
      def build_runner(step_mother, io)
        Ast::TreeWalker.new(step_mother, formatters(step_mother), @options, io)
      end

      def formatter_class(format)
        if(builtin = Options::BUILTIN_FORMATS[format])
          constantize(builtin[0])
        else
          constantize(format)
        end
      end

      def all_files_to_load
        requires = @options[:require].empty? ? require_dirs : @options[:require]
        files = requires.map do |path|
          path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
          path = path.gsub(/\/$/, '') # Strip trailing slash.
          File.directory?(path) ? Dir["#{path}/**/*"] : path
        end.flatten.uniq
        remove_excluded_files_from(files)
        files.reject! {|f| !File.file?(f)}
        files.reject! {|f| File.extname(f) == '.feature' }
        files.reject! {|f| f =~ /^http/}
        files      
      end
      
      def step_defs_to_load
        all_files_to_load.reject {|f| f =~ %r{/support/} }
      end
      
      def support_to_load
        support_files = all_files_to_load.select {|f| f =~ %r{/support/} }
        env_files = support_files.select {|f| f =~ %r{/support/env\..*} }
        other_files = support_files - env_files
        @options[:dry_run] ? other_files : env_files + other_files
      end

      def feature_files
        potential_feature_files = paths.map do |path|
          path = path.gsub(/\\/, '/') # In case we're on windows. Globs don't work with backslashes.
          path = path.chomp('/')
          if File.directory?(path)
            Dir["#{path}/**/*.feature"]
          elsif path[0..0] == '@' and # @listfile.txt
              File.file?(path[1..-1]) # listfile.txt is a file
            IO.read(path[1..-1]).split
          else 
            path
          end
        end.flatten.uniq
        remove_excluded_files_from(potential_feature_files)
        potential_feature_files.sort
      end
      
      def feature_dirs
        paths.map { |f| File.directory?(f) ? f : File.dirname(f) }.uniq
      end

      def log
        logger = Logger.new(@out_stream)
        logger.formatter = LogFormatter.new
        logger.level = Logger::INFO
        logger.level = Logger::DEBUG if self.verbose?
        logger
      end

    private
    
      def formatters(step_mother)
        return [Formatter::Pretty.new(step_mother, nil, @options)] if @options[:autoformat]
        @options[:formats].map do |format_and_out|
          format = format_and_out[0]
          out    = format_and_out[1]
          if String === out # file name
            unless File.directory?(out)
              out = File.open(out, Cucumber.file_mode('w'))
              at_exit do
                
                # Since Spork "never" actually exits, I want to flush and close earlier...
                unless out.closed?
                  out.flush
                  out.close
                end
                
              end
            end
          end

          begin
            formatter_class = formatter_class(format)
            formatter_class.new(step_mother, out, @options)
          rescue Exception => e
            e.message << "\nError creating formatter: #{format}"
            raise e
          end
        end
      end

      class LogFormatter < ::Logger::Formatter
        def call(severity, time, progname, msg)
          msg
        end
      end

      def paths
        @options[:paths].empty? ? ['features'] : @options[:paths]
      end

      def set_environment_variables
        @options[:env_vars].each do |var, value|
          ENV[var] = value
        end
      end

      def arrange_formats
        @options[:formats] << ['pretty', @out_stream] if @options[:formats].empty?
        @options[:formats] = @options[:formats].sort_by{|f| f[1] == @out_stream ? -1 : 1}
        streams = @options[:formats].map { |(_, stream)| stream }
        if streams != streams.uniq
          raise "All but one formatter must use --out, only one can print to each stream (or STDOUT)"
        end
      end

      def remove_excluded_files_from(files)
        files.reject! {|path| @options[:excludes].detect {|pattern| path =~ pattern } }
      end

      def require_dirs
        feature_dirs + Dir['vendor/{gems,plugins}/*/cucumber']
      end
      
    end

  end
end
