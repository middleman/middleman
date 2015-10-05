module Middleman
  module Profiling
    # The profiler instance. There can only be one!
    def self.profiler=(prof)
      @profiler = prof
    end

    def self.profiler
      @profiler ||= NullProfiler.new
    end

    # Start the profiler
    def self.start
      profiler.start
    end

    # Stop the profiler and generate a report. Make sure to call start first
    def self.report(report_name)
      profiler.report(report_name)
    end

    # A profiler that does nothing. The default.
    class NullProfiler
      def start
      end

      def report(_)
      end
    end

    # A profiler that uses ruby-prof
    class RubyProfProfiler
      def initialize
        require 'ruby-prof'
      rescue LoadError
        raise "To use the --profile option, you must add the 'ruby-prof' gem to your Gemfile"
      end

      def start
        RubyProf.start
      end

      def report(report_name)
        result = RubyProf.stop

        printer = RubyProf::GraphHtmlPrinter.new(result)
        outfile = File.join('profile', report_name)
        outfile = (outfile + '.html') unless outfile.end_with? '.html'
        FileUtils.mkdir_p(File.dirname(outfile))
        File.open(outfile, 'w') do |f|
          printer.print(f, min_percent: 1)
        end
      end
    end
  end
end
