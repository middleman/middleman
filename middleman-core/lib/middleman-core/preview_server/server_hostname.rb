module Middleman
  class PreviewServer
    class ServerHostname
      class ServerFullHostname < SimpleDelegator
        def to_s
          __getobj__.gsub(/\s/, '+')
        end

        def self.match?(*)
          true
        end

        alias to_browser to_s
      end

      class ServerPlainHostname < SimpleDelegator
        def to_s
          __getobj__.gsub(/\s/, '+') + '.local'
        end

        def self.match?(name)
          # rubocop:disable Style/CaseEquality
          name != 'localhost' && /^(?=.{1,255}$)[0-9A-Za-z](?:(?:[0-9A-Za-z]|-){0,61}[0-9A-Za-z])?\.?$/ === name
          # rubocop:enable Style/CaseEquality
        end

        alias to_browser to_s
      end

      def self.new(string)
        @names = []
        @names << ServerPlainHostname
        @names << ServerFullHostname

        @names.find { |n| n.match? string }.new(string)
      end
    end
  end
end
