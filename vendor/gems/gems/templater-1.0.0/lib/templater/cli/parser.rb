require 'optparse'
require 'optparse/time'

module Templater

  module CLI

    class Parser #:nodoc:

      def self.parse(args)
        # The options specified on the command line will be collected in *options*.
        # We set default values here.
        options = {}
        options[:pretend] = false
        options[:force] = false
        options[:skip] = false
        options[:quiet] = false
        options[:verbose] = false
        options[:help] = false
        options[:version] = false

        opts = OptionParser.new do |opts|

          opts.banner = ""

          if block_given?
            yield opts, options
            opts.separator ""
          end

          opts.separator "General options:"

          opts.on("-p", "--pretend", "Run, but do not make any changes.") do |s|
            options[:pretend] = s
          end

          opts.on("-f", "--force", "Overwrite files that already exist.") do |s|
            options[:force] = s
          end

          opts.on("-s", "--skip", "Skip files that already exist.") do |s|
            options[:skip] = s
          end
        
          opts.on("-d", "--delete", "Delete files that have previously been generated with this generator.") do |s|
            options[:delete] = s
          end
        
          opts.on("--no-color", "Don't colorize the output") do
            options[:no_color] = true
          end

          opts.on("-h", "--help", "Show this message") do
            options[:help] = true
          end
          
          opts.on("--debug", "Do not catch errors") do
            options[:debug] = true
          end

        end
      
        def opts.inspect; "<#OptionParser #{object_id}>"; end
      
        options[:opts] = opts

        begin
          opts.parse!(args)
        rescue OptionParser::InvalidOption => e
          puts
          puts error_message(e)
          puts
        end

        options
      end

      def self.error_message(e)
        "One or more unknown options given: #{e.args.join(', ')}"
      end
    end
  
  end

end