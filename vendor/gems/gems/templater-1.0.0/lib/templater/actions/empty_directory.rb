module Templater
  module Actions
    class EmptyDirectory < Action

      # Builds a new Directory
      # 
      # === Parameters
      # generator<Object>:: The generator
      # name<Symbol>:: The name of this directory
      # destination<String>:: Full path to the destination of this directory
      # options<Hash{Symbol=>Symbol}:: Options, including callbacks.
      def initialize(generator, name, destination, options={})
        self.generator = generator
        self.name = name
        self.destination = destination
        self.options = options
      end

      # Returns an empty String: there's nothing to read from.
      #
      # === Returns
      # String:: The source file.
      def render
        ''
      end

      # Checks if the destination file already exists.
      #
      # === Returns
      # Boolean:: true if the file exists, false otherwise.
      def exists?
        ::File.exists?(destination)
      end
  
      # For empty directory this is in fact alias for exists? method.
      # 
      # === Returns
      # Boolean:: true if it is identical, false otherwise.
      def identical?
        exists?
      end
  
      # Renders the template and copies it to the destination.
      def invoke!
        callback(:before)
        ::FileUtils.mkdir_p(destination)
        callback(:after)
      end
    
      # removes the destination file
      def revoke!
        ::FileUtils.rm_rf(::File.expand_path(destination))
      end

    end # EmptyDirectory
  end # Actions
end # Templater
