module Templater
  module Actions
    class File < Action
  
      # Builds a new file.
      #
      # === Parameters
      # generator<Object>:: The generator
      # name<Symbol>:: The name of this file
      # source<String>:: Full path to the source of this file
      # destination<String>:: Full path to the destination of this file
      # options<Hash{Symbol=>Symbol}:: Options, including callbacks.
      def initialize(generator, name, source, destination, options={})
        self.generator = generator
        self.name = name
        self.source = source
        self.destination = destination
        self.options = options
      end

      # Returns the contents of the source file as a String
      #
      # === Returns
      # String:: The source file.
      def render
        ::File.read(source)
      end

      # Checks if the destination file already exists.
      #
      # === Returns
      # Boolean:: true if the file exists, false otherwise.
      def exists?
        ::File.exists?(destination)
      end
  
      # Checks if the content of the file at the destination is identical to the rendered result.
      # 
      # === Returns
      # Boolean:: true if it is identical, false otherwise.
      def identical?
        exists? && ::FileUtils.identical?(source, destination)
      end
  
      # Renders the template and copies it to the destination.
      def invoke!
        callback(:before)
        ::FileUtils.mkdir_p(::File.dirname(destination))
        ::FileUtils.cp_r(source, destination)
        callback(:after)
      end
    
      # removes the destination file
      def revoke!
        ::FileUtils.rm_r(destination, :force => true)
      end

    end
  end
end
