# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{shotgun}
  s.version = "0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Tomayko"]
  s.date = %q{2009-03-22}
  s.default_executable = %q{shotgun}
  s.description = %q{Because reloading sucks.}
  s.email = %q{r@tomayko.com}
  s.executables = ["shotgun"]
  s.extra_rdoc_files = ["README"]
  s.files = ["README", "COPYING", "Rakefile", "shotgun.gemspec", "lib/shotgun.rb", "bin/shotgun"]
  s.homepage = %q{http://github.com/rtomayko/shotgun/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{wink}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Because reloading sucks.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0.9.1"])
      s.add_runtime_dependency(%q<launchy>, [">= 0.3.3", "< 1.0"])
    else
      s.add_dependency(%q<rack>, [">= 0.9.1"])
      s.add_dependency(%q<launchy>, [">= 0.3.3", "< 1.0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0.9.1"])
    s.add_dependency(%q<launchy>, [">= 0.3.3", "< 1.0"])
  end
end
