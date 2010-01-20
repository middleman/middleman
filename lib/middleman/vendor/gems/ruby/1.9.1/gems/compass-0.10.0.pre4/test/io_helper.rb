module Compass
  module IoHelper
    def capture_output
      real_stdout, $stdout = $stdout, StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = real_stdout
    end

    def capture_warning
      real_stderr, $stderr = $stderr, StringIO.new
      yield
      $stderr.string
    ensure
      $stderr = real_stderr
    end

    def capture_pipe(io, options = {})
      options[:wait] = 0.25
      options[:timeout] = 1.0
      output = ""
      eof_at = nil
      while !eof_at || (Time.now - eof_at < options[:wait])
        if io.eof?
          eof_at ||= Time.now
          sleep 0.1
        else
          eof_at = nil
          timeout(options[:timeout]) { output << io.readpartial(1024) }
        end
      end
      output
    end
  end
end
