# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sinatra-content-for}
  s.version = "0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nicolás Sanguinetti"]
  s.date = %q{2009-05-08}
  s.description = %q{Small Sinatra extension to add a content_for helper similar to Rails'}
  s.email = %q{contacto@nicolassanguinetti.info}
  s.files = [".gitignore", "LICENSE", "README.rdoc", "sinatra-content-for.gemspec", "lib/sinatra/content_for.rb", "test/content_for_test.rb"]
  s.homepage = %q{http://sinatrarb.com}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{sinatra-ditties}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Small Sinatra extension to add a content_for helper similar to Rails'}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, [">= 0"])
      s.add_development_dependency(%q<contest>, [">= 0"])
      s.add_development_dependency(%q<sr-mg>, [">= 0"])
      s.add_development_dependency(%q<redgreen>, [">= 0"])
    else
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<contest>, [">= 0"])
      s.add_dependency(%q<sr-mg>, [">= 0"])
      s.add_dependency(%q<redgreen>, [">= 0"])
    end
  else
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<contest>, [">= 0"])
    s.add_dependency(%q<sr-mg>, [">= 0"])
    s.add_dependency(%q<redgreen>, [">= 0"])
  end
end
