# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{term-ansicolor}
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Florian Frank"]
  s.date = %q{2009-07-22}
  s.description = %q{}
  s.email = %q{flori@ping.de}
  s.extra_rdoc_files = ["doc-main.txt"]
  s.files = ["CHANGES", "COPYING", "README", "Rakefile", "VERSION", "examples/cdiff.rb", "examples/example.rb", "install.rb", "lib/term/ansicolor.rb", "lib/term/ansicolor/version.rb", "term-ansicolor.gemspec", "doc-main.txt"]
  s.homepage = %q{http://term-ansicolor.rubyforge.org}
  s.rdoc_options = ["--main", "doc-main.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{term-ansicolor}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Ruby library that colors strings using ANSI escape sequences}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
