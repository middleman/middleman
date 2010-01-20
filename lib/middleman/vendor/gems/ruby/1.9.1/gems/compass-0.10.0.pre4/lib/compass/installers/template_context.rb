module Compass
  module Installers
    class TemplateContext

      def self.ctx(*arguments)
        new(*arguments).send(:get_binding)
      end

      def initialize(template, locals = {})
        @template = template
        @locals = locals
      end

      def http_stylesheets_path
        config.http_stylesheets_path ||
        config.default_for(:http_stylesheets_path) ||
        config.http_root_relative(config.css_dir)
      end

      Compass::Configuration::ATTRIBUTES.each do |attribute|
        unless instance_methods.include?(attribute.to_s)
          define_method attribute do
            config.send(attribute) || config.default_for(attribute)
          end
        end
      end

      def config
        Compass.configuration
      end

      alias configuration config

      protected

      def get_binding
        @locals.each do |k, v|
          eval("#{k} = v")
        end
        binding
      end
    end
  end
end