require 'sass/plugin'

# XXX: We can remove this monkeypatch once Sass 2.2 is released.
module Sass::Plugin

  # splits the stylesheet_needs_update? method into two pieces so I can use the exact_stylesheet_needs_update? piece
  module StylesheetNeedsUpdate
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

  # At some point Sass::Plugin changed from using the metaclass to extend self.
  metaclass = class << self; self; end
  if metaclass.included_modules.include?(Sass::Plugin)
    if method(:stylesheet_needs_update?).arity == 2
      alias exact_stylesheet_needs_update? stylesheet_needs_update?
    elsif !method_defined?(:exact_stylesheet_needs_update?)
      include StylesheetNeedsUpdate
    end
  else
    class << self
      unless method_defined?(:exact_stylesheet_needs_update?)
        include StylesheetNeedsUpdate
      end
    end
  end

end
