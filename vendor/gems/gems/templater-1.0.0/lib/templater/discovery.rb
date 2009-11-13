module Templater
  
  # This provides a hook system which programs that use Templater can use to discover generators
  # installed through gems. This requires two separate things, the Templater-using progrma will
  # have to call the #discover! method giving a scope, like this:
  #
  #     Templater::Discovery.discover!("name-of-scope")
  #
  # Where "name-of-scope" should be a string that uniquely identifies your program. Any gem wishing
  # to then add a generator, that is automatically picked up, will then need to add a Generators
  # file at the root of the project (don't forget to add it to the gem's manifest of files).
  #
  #     - lib /
  #     - spec /
  #     - Rakefile
  #     - Generators
  #
  # This file should look something like this:
  #
  #     scope "name-of-scope" do
  #       require ...something...
  #     end
  #
  # Multiple scopes can be added to the same Generators file for use with different generator
  # programs.
  module Discovery
    
    extend self
    
    # Adds a block of code specific for a certain scope of generators, where the scope would
    # probably be the name of the program running the generator.
    #
    # === Parameters
    # scope<String>:: The name of the scope
    # block<&Proc>:: A block of code to execute provided the scope is correct
    def scope(scope, &block)
      @scopes[scope] ||= []
      @scopes[scope] << block
    end
    
    # Searches installed gems for Generators files and loads all code blocks in them that match
    # the given scope.
    #
    # === Parameters
    # scope<String>:: The name of the scope to search for
    def discover!(scope)
      @scopes = {}
      generator_files.each do |file|
        load file
      end
      @scopes[scope].each { |block| block.call } if @scopes[scope]
    end
    
    protected
    
    def find_latest_gem_paths
      # Minigems provides a simpler (and much faster) method for finding the
      # latest gems.
      if Gem.respond_to?(:latest_gem_paths)
        Gem.latest_gem_paths
      else
        gems = Gem.cache.inject({}) do |latest_gems, cache|
          name, gem = cache
          currently_latest = latest_gems[gem.name]
          latest_gems[gem.name] = gem if currently_latest.nil? or gem.version > currently_latest.version
          latest_gems
        end
        gems.values.map{|g| g.full_gem_path}
      end
    end

    def generator_files
      find_latest_gem_paths.inject([]) do |files, gem_path|
        path = ::File.join(gem_path, "Generators")
        files << path if ::File.exists?(path) and not ::File.directory?(path)
        files
      end
    end
    
  end

end

def scope(scope, &block) #:nodoc:
  Templater::Discovery.scope(scope, &block)
end