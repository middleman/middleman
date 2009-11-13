module Templater
  
  module Manifold
    
    # Lists all generators in this manifold
    #
    # === Returns
    # Array[Templater::Generator]:: A list of generators
    def generators
      private_generators.merge(public_generators)
    end
    
    # Lists all public generators, these are generators that are meant to be invoked directly by the user.
    #
    # === Returns
    # Array[Templater::Generator]:: A list of generators
    def public_generators
      @public_generators ||= {} 
    end
    
    # Lists all private generators, these are generators that are meant to be used only internally
    # and should not be invoked directly (although the interface may choose to do so)
    #
    # === Returns
    # Array[Templater::Generator]:: A list of generators
    def private_generators
      @private_generators ||= {} 
    end
    
    # Add a generator to this manifold
    # 
    # === Parameters
    # name<Symbol>:: The name given to this generator in the manifold
    # generator<Templater::Generator>:: The generator class
    def add_public(name, generator)
      public_generators[name.to_sym] = generator
      generator.manifold = self
    end
    
    alias_method :add, :add_public
    
    # Add a generator for internal use to this manifold.
    # 
    # === Parameters
    # name<Symbol>:: The name given to this generator in the manifold
    # generator<Templater::Generator>:: The generator class
    def add_private(name, generator)
      private_generators[name.to_sym] = generator
      generator.manifold = self
    end
    
    # Remove the generator with the given name from the manifold
    #
    # === Parameters
    # name<Symbol>:: The name of the generator to be removed.
    def remove(name)
      public_generators.delete(name.to_sym)
      private_generators.delete(name.to_sym)
    end
    
    # Finds the class of a generator, given its name in the manifold.
    #
    # === Parameters
    # name<Symbol>:: The name of the generator to find
    #
    # === Returns
    # Templater::Generator:: The found generator class
    def generator(name)
      generators[name.to_sym]
    end
    
    # A Shortcut method for invoking the command line interface provided with Templater.
    #
    # === Parameters
    # destination_root<String>:: Where the generated files should be put, this would usually be Dir.pwd
    # name<String>:: The name of the executable running this generator (such as 'merb-gen')
    # version<String>:: The version number of the executable.
    # args<Array[String]>:: An array of arguments to pass into the generator. This would usually be ARGV
    def run_cli(destination_root, name, version, args)
      Templater::CLI::Manifold.run(destination_root, self, name, version, args)
    end
    
    # If the argument is omitted, simply returns the description for this manifold, otherwise
    # sets the description to the passed string.
    #
    # === Parameters
    # text<String>:: A description
    #
    # === Returns
    # String:: The description for this manifold
    def desc(text = nil)
      @text = text if text
      return @text.realign_indentation
    end
    
  end
  
end