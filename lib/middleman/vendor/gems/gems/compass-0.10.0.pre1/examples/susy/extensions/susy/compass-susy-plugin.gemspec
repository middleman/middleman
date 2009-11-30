# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{compass-susy-plugin}
  s.version = "0.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Meyer"]
  s.date = %q{2009-07-12}
  s.description = %q{Susy is a ground-up native Compass plugin grid system that takes full advantage of Sass' capabilities to remove the tedium from grid-based web design.}
  s.email = %q{eric@oddbird.net}
  s.extra_rdoc_files = ["lib/susy/compass_plugin.rb", "lib/susy/sass_extensions.rb", "lib/susy.rb", "README.mkdn"]
  s.files = ["lib/susy/compass_plugin.rb", "lib/susy/sass_extensions.rb", "lib/susy.rb", "Manifest", "Rakefile", "README.mkdn", "sass/susy/_grid.sass", "sass/susy/_utils.sass", "sass/susy/_text.sass", "sass/susy/_susy.sass", "templates/project/_base.sass", "templates/project/screen.sass", "templates/project/print.sass", "templates/project/ie.sass", "templates/project/manifest.rb", "VERSION", "LICENSE.txt", "docs/tutorial/index.mkdn", "docs/tutorial/figures/susy_element.png", "docs/tutorial/figures/susy_grid.png", "compass-susy-plugin.gemspec"]
  s.homepage = %q{http://github.com/ericam/compass-susy-plugin}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Compass-Susy-plugin", "--main", "README.mkdn"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.3}
  s.summary = %q{A Compass grid system plugin.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<compass>, [">= 0"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
    else
      s.add_dependency(%q<compass>, [">= 0"])
      s.add_dependency(%q<echoe>, [">= 0"])
    end
  else
    s.add_dependency(%q<compass>, [">= 0"])
    s.add_dependency(%q<echoe>, [">= 0"])
  end
end
