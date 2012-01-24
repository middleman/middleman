module Padrino
  module Cli
    module Adapter
      class << self
        # Start for the given options a rackup handler
        def start(options)
          Padrino.run!(options.symbolize_keys)
        end

        # Method that stop (if exist) a running Padrino.application
        def stop(options)
          options.symbolize_keys!
          if File.exist?(options[:pid])
            pid = File.read(options[:pid]).to_i
            print "=> Sending INT to process with pid #{pid} wait "
            Process.kill(2, pid) rescue nil
          else
            puts "=> #{options[:pid]} not found!"
          end
        end
      end # self
    end # Adapter
  end # Cli
end # Padrino
