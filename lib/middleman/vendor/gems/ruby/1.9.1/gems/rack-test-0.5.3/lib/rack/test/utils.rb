module Rack
  module Test

    module Utils # :nodoc:
      include Rack::Utils

      def build_nested_query(value, prefix = nil)
        case value
        when Array
          value.map do |v|
            build_nested_query(v, "#{prefix}[]")
          end.join("&")
        when Hash
          value.map do |k, v|
            build_nested_query(v, prefix ? "#{prefix}[#{escape(k)}]" : escape(k))
          end.join("&")
        when NilClass
          prefix.to_s
        else
          "#{prefix}=#{escape(value)}"
        end
      end

      module_function :build_nested_query

      def build_multipart(params, first = true)
        if first
          unless params.is_a?(Hash)
            raise ArgumentError, "value must be a Hash"
          end

          multipart = false
          query = lambda { |value|
            case value
            when Array
              value.each(&query)
            when Hash
              value.values.each(&query)
            when UploadedFile
              multipart = true
            end
          }
          params.values.each(&query)
          return nil unless multipart
        end

        flattened_params = Hash.new

        params.each do |key, value|
          k = first ? key.to_s : "[#{key}]"

          case value
          when Array
            value.map { |v|
              build_multipart(v, false).each { |subkey, subvalue|
                flattened_params["#{k}[]#{subkey}"] = subvalue
              }
            }
          when Hash
            build_multipart(value, false).each { |subkey, subvalue|
              flattened_params[k + subkey] = subvalue
            }
          else
            flattened_params[k] = value
          end
        end

        if first
          flattened_params.map { |name, file|
            if file.respond_to?(:original_filename)
              ::File.open(file.path, "rb") do |f|
                f.set_encoding(Encoding::BINARY) if f.respond_to?(:set_encoding)
<<-EOF
--#{MULTIPART_BOUNDARY}\r
Content-Disposition: form-data; name="#{name}"; filename="#{escape(file.original_filename)}"\r
Content-Type: #{file.content_type}\r
Content-Length: #{::File.stat(file.path).size}\r
\r
#{f.read}\r
EOF
              end
            else
<<-EOF
--#{MULTIPART_BOUNDARY}\r
Content-Disposition: form-data; name="#{name}"\r
\r
#{file}\r
EOF
            end
          }.join + "--#{MULTIPART_BOUNDARY}--\r"
        else
          flattened_params
        end
      end

      module_function :build_multipart

    end

  end
end
