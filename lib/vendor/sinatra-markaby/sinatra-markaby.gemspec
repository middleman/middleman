# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sinatra-markaby}
  s.version = "0.9.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["S. Brent Faulkner"]
  s.date = %q{2009-04-29}
  s.description = %q{Sinatra plugin to enable markaby (.mab) template rendering.}
  s.email = %q{brentf@unwwwired.net}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/sinatra/markaby.rb",
    "test/sinatra_markaby_test.rb",
    "test/test_helper.rb",
    "test/views/hello.mab"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/sbfaulkner/sinatra-markaby}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Sinatra plugin to enable markaby (.mab) template rendering.}
  s.test_files = [
    "test/sinatra_markaby_test.rb",
    "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<markaby>, [">= 0"])
    else
      s.add_dependency(%q<markaby>, [">= 0"])
    end
  else
    s.add_dependency(%q<markaby>, [">= 0"])
  end
end
