module Middleman
  module Configuration
    # A class that manages a collection of documented settings.
    # Can be used by extensions as well as the main Middleman
    # application. Extensions should probably finalize their instance
    # after defining all the settings they want to expose.
    class ConfigurationManager
      def initialize
        # A hash from setting key to ConfigSetting instance.
        @settings = {}
        @finalized = false
      end

      # Get all settings, sorted by key, as ConfigSetting objects.
      # @return [Array<ConfigSetting>]
      def all_settings
        @settings.values.sort_by(&:key)
      end

      # Get a full ConfigSetting object for the setting with the give key.
      # @return [ConfigSetting]
      def setting(key)
        @settings[key]
      end

      # Get the value of a setting by key. Returns nil if there is no such setting.
      # @return [Object]
      def [](key)
        setting_obj = setting(key)
        setting_obj ? setting_obj.value : nil
      end

      # Set the value of a setting by key. Creates the setting if it doesn't exist.
      # @param [Symbol] key
      # @param [Object] val
      def []=(key, val)
        setting_obj = setting(key) || define_setting(key)
        setting_obj.value = val
      end

      # Allow configuration settings to be read and written via methods
      def method_missing(method, *args)
        if defines_setting?(method) && args.empty?
          self[method]
        elsif method.to_s =~ /^(\w+)=$/ && args.size == 1
          self[$1.to_sym] = args[0]
        else
          super
        end
      end

      # Needed so that method_missing makes sense
      def respond_to?(method, include_private=false)
        super || defines_setting?(method) || (method =~ /^(\w+)=$/ && defines_setting?($1))
      end

      # Does this configuration manager know about the setting identified by key?
      # @param [Symbol] key
      # @return [Boolean]
      def defines_setting?(key)
        @settings.key?(key)
      end

      # Define a new setting, with optional default and user-friendly description.
      # Once the configuration manager is finalized, no new settings may be defined.
      #
      # @example
      #   config.define_setting :compress, false, 'Whether to compress the output'
      # @param [Symbol] key The name of the option
      # @param [Object] default The default value for the option
      # @param [String] description A human-readable description of what the option does
      # @param [Hash] options Additional options.
      # @return [ConfigSetting]
      def define_setting(key, default=nil, description=nil, options={})
        raise "Setting #{key} doesn't exist" if @finalized
        raise "Setting #{key} already defined" if @settings.key?(key)
        raise 'Setting key must be a Symbol' unless key.is_a? Symbol

        @settings[key] = ConfigSetting.new(key, default, description, options)
      end

      # Switch the configuration manager is finalized, it switches to read-only
      # mode and no new settings may be defined.
      def finalize!
        @finalized = true
        self
      end

      # Deep duplicate of the configuration manager
      def dup
        ConfigurationManager.new.tap { |c| c.load_settings(all_settings) }
      end

      # Load in a list of settings
      def load_settings(other_settings)
        other_settings.each do |setting|
          new_setting = define_setting(setting.key, setting.default, setting.description, setting.options)
          new_setting.value = setting.value if setting.value_set?
        end
      end

      def to_h
        hash = {}
        @settings.each do |key, setting|
          hash[key] = setting.value
        end
        hash
      end

      def to_s
        to_h.inspect
      end
    end

    # An individual configuration setting, with an optional default and description.
    # Also models whether or not a value has been set.
    class ConfigSetting
      # The name of this setting
      attr_accessor :key

      # The default value for this setting
      attr_accessor :default

      # A human-friendly description of the setting
      attr_accessor :description

      # Additional config.
      attr_accessor :options

      def initialize(key, default, description, options={})
        @value_set = false
        self.key = key
        self.default = default
        self.description = description
        self.options = options
      end

      # The user-supplied value for this setting, overriding the default
      def value=(value)
        @value = value
        @value_set = true
      end

      # The effective value of the setting, which may be the default
      # if the user has not set a value themselves. Note that even if the
      # user sets the value to nil it will override the default.
      def value
        value_set? ? @value : default
      end

      # Whether or not there has been a value set beyond the default
      def value_set?
        @value_set == true
      end
    end
  end
end
