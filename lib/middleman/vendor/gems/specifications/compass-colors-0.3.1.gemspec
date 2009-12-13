# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{compass-colors}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chris Eppstein"]
  s.date = %q{2009-11-19}
  s.description = %q{Sass Extensions and color theme templates to make working with colors easier and more maintainable.}
  s.email = %q{chris@eppsteins.net}
  s.extra_rdoc_files = ["README.markdown"]
  s.files = ["README.markdown", "Rakefile", "VERSION.yml", "example/config.rb", "example/split_compliment_example.html", "example/src/_split_compliment_theme.sass", "example/src/screen.sass", "lib/compass-colors.rb", "lib/compass-colors/compass_extension.rb", "lib/compass-colors/hsl.rb", "lib/compass-colors/sass_extensions.rb", "spec/approximate_color_matching.rb", "spec/sass_extensions_spec.rb", "templates/analogous/_theme.sass", "templates/analogous/manifest.rb", "templates/basic/_theme.sass", "templates/basic/manifest.rb", "templates/complementary/_theme.sass", "templates/complementary/manifest.rb", "templates/split_complement/_theme.sass", "templates/split_complement/manifest.rb", "templates/triadic/_theme.sass", "templates/triadic/manifest.rb"]
  s.homepage = %q{http://compass-style.org}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Color Support for Compass & Sass}
  s.test_files = ["spec/approximate_color_matching.rb", "spec/sass_extensions_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<compass>, [">= 0.8.7"])
    else
      s.add_dependency(%q<compass>, [">= 0.8.7"])
    end
  else
    s.add_dependency(%q<compass>, [">= 0.8.7"])
  end
end
