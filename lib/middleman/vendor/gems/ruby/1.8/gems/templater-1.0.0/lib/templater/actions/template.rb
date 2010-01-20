module Templater
  module Actions
    class Template < Action
  
      # Builds a new template.
      #
      # === Parameters
      # generator<Object>:: Context for rendering
      # name<Symbol>:: The name of this template
      # source<String>:: Full path to the source of this template
      # destination<String>:: Full path to the destination of this template
      # options<Hash{Symbol=>Symbol}:: Options, including callbacks.
      def initialize(generator, name, source, destination, options={})
        self.generator = generator
        self.name = name
        self.source = source
        self.destination = destination
        self.options = options
      end
  
      # Renders the template using ERB and returns the result as a String.
      #
      # === Returns
      # String:: The rendered template.
      def render
        context = generator.instance_eval 'binding'
        ERB.new(::File.read(source), nil, '-').result(context)
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
        ::File.read(destination) == render if ::File.exists?(destination)
      end
  
      # Renders the template and copies it to the destination.
      def invoke!
        callback(:before)
        ::FileUtils.mkdir_p(::File.dirname(destination))
        ::File.open(destination, 'w') {|f| f.write render }
        callback(:after)
      end
    
      # removes the destination file
      def revoke!
        ::FileUtils.rm(destination, :force => true)
      end
      
    end
  end
end
