module Spec
  module Runner
    class BacktraceTweaker
      def initialize(*patterns)
        @ignore_patterns = []
      end

      def clean_up_double_slashes(line)
        line.gsub!('//','/')
      end

      def ignore_patterns(*patterns)
        # do nothing. Only QuietBacktraceTweaker ignores patterns.
      end

      def ignored_patterns
        []
      end

      def tweak_backtrace(error)
        return if error.backtrace.nil?
        tweaked = error.backtrace.collect do |message|
          clean_up_double_slashes(message)
          kept_lines = message.split("\n").select do |line|
            ignored_patterns.each do |ignore|
              break if line =~ ignore
            end
          end
          kept_lines.empty?? nil : kept_lines.join("\n")
        end
        error.set_backtrace(tweaked.select {|line| line})
      end
    end

    class NoisyBacktraceTweaker < BacktraceTweaker
    end

    # Tweaks raised Exceptions to mask noisy (unneeded) parts of the backtrace
    class QuietBacktraceTweaker < BacktraceTweaker
      unless defined?(IGNORE_PATTERNS)
        spec_files = Dir["lib/*"].map do |path| 
          subpath = path[1..-1]
          /#{subpath}/
        end
        IGNORE_PATTERNS = spec_files + [
          /\/rspec-[^\/]*\/lib\/spec\//,
          /\/spork-[^\/]*\/lib\/spork\//,
          /\/lib\/ruby\//,
          /bin\/spec:/,
          /bin\/spork:/,
          /bin\/rcov:/,
          /lib\/rspec-rails/,
          /vendor\/rails/,
          # TextMate's Ruby and RSpec plugins
          /Ruby\.tmbundle\/Support\/tmruby.rb:/,
          /RSpec\.tmbundle\/Support\/lib/,
          /temp_textmate\./,
          /mock_frameworks\/rspec/,
          /spec_server/
        ]
      end

      def initialize(*patterns)
        super
        ignore_patterns(*patterns)
      end

      def ignore_patterns(*patterns)
        @ignore_patterns += patterns.flatten.map { |pattern| Regexp.new(pattern) }
      end

      def ignored_patterns
        IGNORE_PATTERNS + @ignore_patterns
      end
    end
  end
end
