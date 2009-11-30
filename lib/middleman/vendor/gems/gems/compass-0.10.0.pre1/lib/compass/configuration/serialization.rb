module Compass
  module Configuration
    # The serialization module manages reading and writing the configuration file(s).
    module Serialization
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.extend ClassMethods
      end

      module ClassMethods
        def new_from_file(config_file)
          data = Data.new(config_file)
          data.parse(config_file)
          data
        end

        def new_from_string(contents, filename)
          data = Data.new(filename)
          data.parse_string(contents, filename)
          data
        end
      end

      module InstanceMethods
        # parses a configuration file which is a ruby script
        def parse(config_file)
          unless File.readable?(config_file)
            raise Compass::Error, "Configuration file, #{config_file}, not found or not readable."
          end
          open(config_file) do |f|
            parse_string(f.read, config_file)
          end
        end

        def parse_string(contents, filename)
          bind = binding
          eval(contents, bind, filename)
          ATTRIBUTES.each do |prop|
            value = eval(prop.to_s, bind) rescue nil
            self.send("#{prop}=", value) if value
          end
          if @added_import_paths
            self.additional_import_paths ||= []
            self.additional_import_paths += @added_import_paths
          end
          issue_deprecation_warnings
        end

        def serialize
          contents = ""
          required_libraries.each do |lib|
            contents << %Q{require '#{lib}'\n}
          end
          contents << "# Require any additional compass plugins here.\n"
          contents << "\n" if required_libraries.any?
          ATTRIBUTES.each do |prop|
            value = send("#{prop}_without_default")
            if value.is_a?(Proc)
              $stderr.puts "WARNING: #{prop} is code and cannot be written to a file. You'll need to copy it yourself."
            end
            if respond_to?("comment_for_#{prop}")
              contents << send("comment_for_#{prop}")
            end
            if block_given? && (to_emit = yield(prop, value))
              contents << to_emit
            else
              contents << serialize_property(prop, value) unless value.nil?
            end
          end
          contents
        end

        def serialize_property(prop, value)
          %Q(#{prop} = #{value.inspect}\n)
        end
        
        def issue_deprecation_warnings
          if http_images_path == :relative
            $stderr.puts "DEPRECATION WARNING: Please set relative_assets = true to enable relative paths."
          end
        end

      end
    end
  end
end
