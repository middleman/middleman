require 'compass/exec/global_options_parser'
require 'compass/exec/project_options_parser'

module Compass::Exec
  class SubCommandUI

    attr_accessor :args

    def initialize(args)
      self.args = args
    end

    def run!
      begin
        perform!
      rescue Exception => e
        raise e if e.is_a? SystemExit
        if e.is_a?(::Compass::Error) || e.is_a?(OptionParser::ParseError)
          $stderr.puts e.message
        else
          ::Compass::Exec::Helpers.report_error(e, @options || {})
        end
        return 1
      end
      return 0
    end
    
    protected
    
    def perform!
      $command = args.shift
      command_class = Compass::Commands[$command]
      @options = if command_class.respond_to?("parse_#{$command}!")
        command_class.send("parse_#{$command}!", args)
      else
        command_class.parse!(args)
      end
      command_class.new(Dir.getwd, @options).execute
    rescue OptionParser::ParseError => e
      puts "Error: #{e.message}"
      puts command_class.usage
    end
    
  end
end
