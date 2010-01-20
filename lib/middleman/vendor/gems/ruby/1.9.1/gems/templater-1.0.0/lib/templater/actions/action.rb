module Templater
  module Actions
    class Action
  
      attr_accessor :generator, :name, :source, :destination, :options
  
      def source=(source)
        unless source.blank?
          @source = ::File.expand_path(source, generator.source_root)
        end
      end
      
      def destination=(destination)
        unless destination.blank?
          @destination = ::File.expand_path(convert_encoded_instructions(destination), generator.destination_root)
        end
      end
    
      # Returns the destination path relative to Dir.pwd. This is useful for prettier output in interfaces
      # where the destination root is Dir.pwd.
      #
      # === Returns
      # String:: The destination relative to Dir.pwd
      def relative_destination
        @destination.relative_path_from(@generator.destination_root)
      end
      
      protected
      
      def callback(name)
        @generator.send(@options[name], self) if @options[name]
      end
      
      def convert_encoded_instructions(filename)
        filename.gsub(/%.*?%/) do |string|
          instruction = string.match(/%(.*?)%/)[1]
          @generator.respond_to?(instruction) ? @generator.send(instruction) : string
        end
      end
      
    end
  end
end
