module Compass
  module RailsHelper
    def generate_rails_app_directories(name)
      Dir.mkdir name
      Dir.mkdir File.join(name, "config")
      Dir.mkdir File.join(name, "config", "initializers")
    end

    # Generate a rails application without polluting our current set of requires
    # with the rails libraries. This will allow testing against multiple versions of rails
    # by manipulating the load path.
    def generate_rails_app(name)
      if pid = fork
        Process.wait(pid)
        if $?.exitstatus == 2
          raise LoadError, "Couldn't load rails"
        elsif $?.exitstatus != 0
          raise "Failed to generate rails application."
        end
      else
        begin
          require 'rails/version'
          require 'rails_generator'
          require 'rails_generator/scripts/generate'
          Rails::Generator::Base.use_application_sources!
          capture_output do
            Rails::Generator::Base.logger = Rails::Generator::SimpleLogger.new $stdout
            Rails::Generator::Scripts::Generate.new.run([name], :generator => 'app')
          end
        rescue LoadError
          Kernel.exit!(2)
        rescue => e
          $stderr.puts e
          Kernel.exit!(1)
        end
        Kernel.exit!(0)
      end
    end
  end
end
