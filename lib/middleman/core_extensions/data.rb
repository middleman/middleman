# Data formats
require "yaml"
require "active_support/json"

# Using Thor's indifferent hash access
require "thor"

# The data extension parses YAML and JSON files in the data/ directory
# and makes them available to config.rb, templates and extensions
module Middleman::CoreExtensions::Data
  
  # Extension registered
  class << self
    # @private
    def registered(app)
      app.set :data_dir, "data"
      app.send :include, InstanceMethods
    end
    alias :included :registered
  end
  
  # Instance methods
  module InstanceMethods
    # Setup data files before anything else so they are available when
    # parsing config.rb
    def initialize
      file_changed DataStore.matcher do |file|
        data.touch_file(file) if file.match(%r{^#{data_dir}\/})
      end
    
      file_deleted DataStore.matcher do |file|
        data.remove_file(file) if file.match(%r{^#{data_dir}\/})
      end
      
      super
    end
    
    # The data object
    #
    # @return [DataStore]
    def data
      @data ||= DataStore.new(self)
    end

    # Makes a hash available on the data var with a given name
    #
    # @param [Symbol] name Name of the data, used for namespacing
    # @param [Hash] content The content for this data
    # @return [void]
    def data_content(name, content)
      DataStore.data_content(name, content)
    end

    # Makes a hash available on the data var with a given name
    #
    # @param [Symbol] name Name of the data, used for namespacing
    # @return [void]
    def data_callback(name, &block)
      DataStore.data_callback(name, block)
    end
  end
  
  # The core logic behind the data extension.
  class DataStore
    
    # Static methods
    class << self
      
      # The regex which tells Middleman which files are for data
      #
      # @return [Regexp]
      def matcher
        %r{[\w-]+\.(yml|yaml|json)$}
      end

      # Store static data hash
      #
      # @param [Symbol] name Name of the data, used for namespacing
      # @param [Hash] content The content for this data
      # @return [void]
      def data_content(name, content)
        @@local_sources ||= {}
        @@local_sources[name.to_s] = content
      end

      # Store callback-based data
      #
      # @param [Symbol] name Name of the data, used for namespacing
      # @param [Proc] proc The callback which will return data
      # @return [void]
      def data_callback(name, proc)
        @@callback_sources ||= {}
        @@callback_sources[name.to_s] = proc
      end
    end
    
    # Setup data store
    #
    # @param [Middleman::Base] app The current instance of Middleman
    def initialize(app)
      @app = app
      @local_data = {}
    end
    
    # Update the internal cache for a given file path
    #
    # @param [String] file The file to be re-parsed
    # @return [void]
    def touch_file(file)
      file = File.expand_path(file, @app.root)
      extension = File.extname(file)
      basename  = File.basename(file, extension)
      
      if %w(.yaml .yml).include?(extension)
        data = YAML.load_file(file)
      elsif extension == ".json"
        data = ActiveSupport::JSON.decode(File.read(file))
      else
        return
      end

      @local_data[basename] = recursively_enhance(data)
    end
    
    # Remove a given file from the internal cache
    #
    # @param [String] file The file to be cleared
    # @return [void]
    def remove_file(file)
      extension = File.extname(file)
      basename  = File.basename(file, extension)
      @local_data.delete(basename) if @local_data.has_key?(basename)
    end
    
    # Get a hash hash from either internal static data or a callback
    #
    # @param [String, Symbol] path The name of the data namespace
    # @return [Hash, nil]
    def data_for_path(path)
      response = nil
      
      @@local_sources ||= {}
      @@callback_sources ||= {}
      
      if @@local_sources.has_key?(path.to_s)
        response = @@local_sources[path.to_s]
      elsif @@callback_sources.has_key?(path.to_s)
        response = @@callback_sources[path.to_s].call()
      end
      
      response
    end
    
    # "Magically" find namespaces of data if they exist
    #
    # @param [String] path The namespace to search for
    # @return [Hash, nil]
    def method_missing(path)
      if @local_data.has_key?(path.to_s)
        return @local_data[path.to_s]
      else
        result = data_for_path(path)
      
        if result
          return recursively_enhance(result)
        end
      end
      
      super
    end
    
    # Convert all the data into a static hash
    #
    # @return [Hash]
    def to_h
      data = {}
      
      @@local_sources ||= {}
      @@callback_sources ||= {}
      
      (@@local_sources || {}).each do |k, v|
        data[k] = data_for_path(k)
      end
      
      (@@callback_sources || {}).each do |k, v|
        data[k] = data_for_path(k)
      end
      
      (@local_data || {}).each do |k, v|
        data[k] = v
      end
      
      data
    end
  
  private 
    # Recursively convert a normal Hash into a HashWithIndifferentAccess
    #
    # @private
    # @param [Hash] data Normal hash
    # @return [Thor::CoreExt::HashWithIndifferentAccess]
    def recursively_enhance(data)
      if data.is_a? Hash
        data = Thor::CoreExt::HashWithIndifferentAccess.new(data)
        data.each do |key, val|
          data[key] = recursively_enhance(val)
        end
        data
      elsif data.is_a? Array
        data.each_with_index do |val, i|
          data[i] = recursively_enhance(val)
        end
        data
      else
        data
      end
    end
  end
end