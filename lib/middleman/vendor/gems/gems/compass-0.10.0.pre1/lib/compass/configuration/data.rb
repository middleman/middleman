module Compass
  module Configuration
    # The Compass configuration data storage class manages configuration data that comes from a variety of
    # different sources and aggregates them together into a consistent API
    # Some of the possible sources of configuration data:
    #   * Compass default project structure for stand alone projects
    #   * App framework specific project structures for rails, etc.
    #   * User supplied explicit configuration
    #   * Configuration data provided via the command line interface
    #
    # There are two kinds of configuration data that doesn't come from the user:
    #
    # 1. Configuration data that is defaulted as if the user had provided it themselves.
    #    This is useful for providing defaults that the user is likely to want to edit
    #    but shouldn't have to provide explicitly when getting started
    # 2. Configuration data that is defaulted behind the scenes because _some_ value is
    #    required.
    class Data

      attr_accessor :required_libraries
      attr_reader :name

      include Compass::Configuration::Inheritance
      include Compass::Configuration::Serialization
      include Compass::Configuration::Adapters

      inherited_accessor *ATTRIBUTES

      def initialize(name, attr_hash = nil)
        raise "I need a name!" unless name
        @name = name
        self.required_libraries = []
        set_all(attr_hash) if attr_hash
        self.top_level = self
      end

      def set_all(attr_hash)
        # assert_valid_keys!(attr_hash)
        attr_hash.each do |a, v|
          if self.respond_to?("#{a}=")
            self.send("#{a}=", v)
          end
        end
      end

      def add_import_path(*paths)
        # The @added_import_paths variable works around an issue where
        # the additional_import_paths gets overwritten during parse
        @added_import_paths ||= []
        @added_import_paths += paths
        self.additional_import_paths ||= []
        self.additional_import_paths += paths
      end

      # When called with a block, defines the asset host url to be used.
      # The block must return a string that starts with a protocol (E.g. http).
      # The block will be passed the root-relative url of the asset.
      # When called without a block, returns the block that was previously set.
      def asset_host(&block)
        if block_given?
          @asset_host = block
        else
          @asset_host
        end
      end

      # When called with a block, defines the cache buster strategy to be used.
      # The block must return nil or a string that can be appended to a url as a query parameter.
      # The returned string must not include the starting '?'.
      # The block will be passed the root-relative url of the asset.
      # If the block accepts two arguments, it will also be passed a File object
      # that points to the asset on disk -- which may or may not exist.
      # When called without a block, returns the block that was previously set.
      def asset_cache_buster(&block)
        if block_given?
          @asset_cache_buster = block
        else
          @asset_cache_buster
        end
      end

      # Require a compass plugin and capture that it occured so that the configuration serialization works next time.
      def require(lib)
        required_libraries << lib
        super
      end

      def relative_assets?
        # the http_images_path is deprecated, but here for backwards compatibility.
        relative_assets || http_images_path == :relative
      end

      private

      def assert_valid_keys!(attr_hash)
        illegal_attrs = attr_hash.keys - ATTRIBUTES
        if illegal_attrs.size == 1
          raise Error, "#{illegal_attrs.first.inspect} is not a valid configuration attribute."
        elsif illegal_attrs.size > 0
          raise Error, "Illegal configuration attributes: #{illegal_attrs.map{|a| a.inspect}.join(", ")}"
        end
      end

    end
  end
end
