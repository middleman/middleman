module Compass
  module Version
    # Returns a hash representing the version.
    # The :major, :minor, and :teeny keys have their respective numbers.
    # The :string key contains a human-readable string representation of the version.
    # The :rev key will have the current revision hash.
    #
    # This method swiped from Haml and then modified, some credit goes to Nathan Weizenbaum
    attr_writer :version
    def version
      return @version if defined?(@version)

      read_version_file

      if r = revision
        @version[:rev] = r
        @version[:string] << " [#{r[0...7]}]"
      end

      @version
    end

    protected

    def scope(file) # :nodoc:
      File.join(File.dirname(__FILE__), '..', '..', file)
    end

    def read_version_file
      require 'yaml'
      @version = YAML::load(File.read(scope('VERSION.yml')))
      @version[:string] = "#{@version[:major]}.#{@version[:minor]}.#{@version[:patch]}"
      @version[:teeny] = @version[:patch]
    end

    def revision
      revision_from_git || revision_from_file
    end

    def revision_from_file
      if File.exists?(scope('REVISION'))
        rev = File.read(scope('REVISION')).strip
        rev if rev =~ /[a-f0-9]+/
      end
    end

    def revision_from_git
      if File.exists?(scope('.git/HEAD'))
        rev = File.read(scope('.git/HEAD')).strip
        if rev =~ /^ref: (.*)$/
          rev = File.read(scope(".git/#{$1}")).strip
        end
      end
    end

  end
end
