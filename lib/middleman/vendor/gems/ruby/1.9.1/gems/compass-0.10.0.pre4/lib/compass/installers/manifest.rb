module Compass
  module Installers

    class Manifest
      include Enumerable

      # A Manifest entry
      class Entry < Struct.new(:type, :from, :options)
        def to
          options[:to] || from
        end
      end

      attr_reader :options
      def initialize(manifest_file = nil, options = {})
        @entries = []
        @options = options
        @generate_config = true
        @compile_after_generation = true
        parse(manifest_file) if manifest_file
      end

      def self.type(t)
        eval <<-END
          def #{t}(from, options = {})
             @entries << Entry.new(:#{t}, from, options)
          end
          def has_#{t}?
            @entries.detect {|e| e.type == :#{t}}
          end
          def each_#{t}
            @entries.select {|e| e.type == :#{t}}.each {|e| yield e}
          end
        END
      end

      type :stylesheet
      type :image
      type :javascript
      type :font
      type :file
      type :html

      def help(value = nil)
        if value
          @help = value
        else
          @help
        end
      end

      attr_reader :welcome_message_options

      def welcome_message(value = nil, options = {})
        if value
          @welcome_message = value
          @welcome_message_options = options
        else
          @welcome_message
        end
      end

      def welcome_message_options
        @welcome_message_options || {}
      end

      def description(value = nil)
        if value
          @description = value
        else
          @description
        end
      end

      # Enumerates over the manifest files
      def each
        @entries.each {|e| yield e}
      end

      def generate_config?
        @generate_config
      end

      def compile?
        @compile_after_generation
      end

      protected

      def no_configuration_file!
        @generate_config = false
      end

      def skip_compilation!
        @compile_after_generation = false
      end

      # parses a manifest file which is a ruby script
      # evaluated in a Manifest instance context
      def parse(manifest_file)
        open(manifest_file) do |f|
          eval(f.read, instance_binding, manifest_file)
        end
      end
      def instance_binding
        binding
      end
    end

  end
end
