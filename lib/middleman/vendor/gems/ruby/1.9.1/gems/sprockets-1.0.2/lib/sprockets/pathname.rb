module Sprockets
  class Pathname
    attr_reader :environment, :absolute_location
    
    def initialize(environment, absolute_location)
      @environment = environment
      @absolute_location = File.expand_path(absolute_location)
    end

    # Returns a Pathname for the location relative to this pathname's absolute location.
    def find(location, kind = :file)
      location = File.join(absolute_location, location)
      File.send("#{kind}?", location) ? Pathname.new(environment, location) : nil
    end

    def parent_pathname
      Pathname.new(environment, File.dirname(absolute_location))
    end

    def source_file
      SourceFile.new(environment, self)
    end
    
    def contents
      IO.read(absolute_location)
    end
    
    def ==(pathname)
      environment == pathname.environment &&
        absolute_location == pathname.absolute_location
    end
    
    def to_s
      absolute_location
    end
  end
end
