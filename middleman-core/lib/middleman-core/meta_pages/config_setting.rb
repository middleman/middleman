module Middleman
  module MetaPages
    # View class for a config entry
    class ConfigSetting
      include Padrino::Helpers::OutputHelpers
      include Padrino::Helpers::TagHelpers

      def initialize(setting)
        @setting = setting
      end

      def render
        content = ""
        key_classes = ['key']
        key_classes << 'modified' if @setting.value_set?
        content << content_tag(:span, @setting.key.inspect, :class => key_classes.join(' '))
        content << " = "
        content << content_tag(:span, @setting.value.inspect, :class => 'value')
        if @setting.default
          content << content_tag(:span, :class => 'default') do
            if @setting.value_set?
              "Default: #{@setting.default.inspect}"
            else
              "(Default)"
            end
          end
        end

        if @setting.description
          content << content_tag(:p, :class => 'description') do
            CGI::escapeHTML(@setting.description)
          end
        end

        content
      end
    end
  end
end
