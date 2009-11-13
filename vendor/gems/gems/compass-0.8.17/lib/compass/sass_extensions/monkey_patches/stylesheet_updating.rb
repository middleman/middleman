require 'sass/plugin'

# XXX: We can remove this monkeypatch once Sass 2.2 is released.
module Sass::Plugin
  class << self
    unless method_defined?(:exact_stylesheet_needs_update?)
      def stylesheet_needs_update?(name, template_path, css_path)
        css_file = css_filename(name, css_path)
        template_file = template_filename(name, template_path)
        exact_stylesheet_needs_update?(css_file, template_file)
      end
      def exact_stylesheet_needs_update?(css_file, template_file)
        if !File.exists?(css_file)
          return true
        else
          css_mtime = File.mtime(css_file)
          File.mtime(template_file) > css_mtime ||
            dependencies(template_file).any?(&dependency_updated?(css_mtime))
        end
      end
    end
  end
end