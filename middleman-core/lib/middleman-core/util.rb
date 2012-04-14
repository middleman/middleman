# Using Thor's indifferent hash access
require "thor"

module Middleman
  module Util
    # Recursively convert a normal Hash into a HashWithIndifferentAccess
    #
    # @private
    # @param [Hash] data Normal hash
    # @return [Thor::CoreExt::HashWithIndifferentAccess]
    def self.recursively_enhance(data)
      if data.is_a? Hash
        data = ::Thor::CoreExt::HashWithIndifferentAccess.new(data)
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
    
    # Normalize a path to not include a leading slash
    # @param [String] path
    # @return [String]
    def self.normalize_path(path)
      path.sub(/^\//, "").gsub("%20", " ")
    end
  end
end