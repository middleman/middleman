# Add module methods to the Middleman module that allow automatically loading
# extensions defined in gems based on the existance of a special file. This also
# adds a method for iterating over all the Gems on a system.
module Middleman
  class << self
    # Where to look in gems for extensions to auto-register. Since most extensions are
    # called out in a Gemfile, this is really only useful for template extensions that get
    # used by "middleman init".
    EXTENSION_FILE = File.join('lib', 'middleman_extension.rb') unless const_defined?(:EXTENSION_FILE)

    # Automatically load extensions from available RubyGems
    # which contain the EXTENSION_FILE
    #
    # @private
    def load_extensions_in_path
      require 'rubygems'

      extensions = rubygems_latest_specs.select do |spec|
        spec_has_file?(spec, EXTENSION_FILE)
      end

      extensions.each do |spec|
        require spec.name
      end
    end

    # Backwards compatible means of finding all the latest gemspecs
    # available on the system
    #
    # @private
    # @return [Array] Array of latest Gem::Specification
    def rubygems_latest_specs
      # If newer Rubygems
      if ::Gem::Specification.respond_to? :latest_specs
        ::Gem::Specification.latest_specs(true)
      else
        ::Gem.source_index.latest_specs
      end
    end

    private

    # Where a given Gem::Specification has a specific file. Used
    # to discover extensions.
    #
    # @private
    # @param [Gem::Specification] spec
    # @param [String] path Path to look for
    # @return [Boolean] Whether the file exists
    def spec_has_file?(spec, path)
      full_path = File.join(spec.full_gem_path, path)
      File.exist?(full_path)
    end
  end
end
