require 'pp'

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
        content = ''
        key_classes = ['key']
        key_classes << 'modified' if @setting.value_set?
        content << content_tag(:span, @setting.key.pretty_inspect.strip, class: key_classes.join(' '))
        content << ' = '
        content << content_tag(:span, @setting.value.pretty_inspect.strip, class: 'value')
        if @setting.default && @setting.value_set? && @setting.default != @setting.value
          content << content_tag(:span, class: 'default') do
            "(Default: #{@setting.default.inspect})"
          end
        end

        if @setting.description
          content << content_tag(:p, class: 'description') do
            @setting.description
          end
        end

        content
      end
    end
  end
end
