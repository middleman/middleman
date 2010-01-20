module Compass::Exec
  module Helpers
    extend self
    def select_appropriate_command_line_ui(arguments)
      if Compass::Commands.command_exists? arguments.first
        SubCommandUI
      else
        SwitchUI
      end
    end
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
  end
end
