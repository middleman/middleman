# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sinatra-maruku}
  s.version = "0.10.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Wlodek Bzyl"]
  s.date = %q{2009-07-26}
  s.description = %q{}
  s.email = %q{matwb@univ.gda.pl}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION.yml",
     "examples/app.rb",
     "examples/config.ru",
     "examples/mapp.rb",
     "examples/public/javascripts/application.js",
     "examples/public/stylesheets/application.css",
     "examples/public/stylesheets/print.css",
     "examples/views/index.maruku",
     "examples/views/layout.maruku",
     "lib/sinatra/maruku.rb",
     "sinatra-maruku.gemspec",
     "test/sinatra_maruku_test.rb",
     "test/test_helper.rb",
     "test/views/hello.maruku",
     "test/views/layout2.maruku"
  ]
  s.homepage = %q{http://github.com/wbzyl/sinatra-maruku}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{An extension providing Maruku templates for Sinatra applications.}
  s.test_files = [
    "test/test_helper.rb",
     "test/sinatra_maruku_test.rb",
     "examples/mapp.rb",
     "examples/app.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sinatra>, [">= 0.10.1"])
      s.add_runtime_dependency(%q<maruku>, [">= 0.6.0"])
      s.add_development_dependency(%q<rack>, [">= 1.0.0"])
      s.add_development_dependency(%q<rack-test>, [">= 0.3.0"])
    else
      s.add_dependency(%q<sinatra>, [">= 0.10.1"])
      s.add_dependency(%q<maruku>, [">= 0.6.0"])
      s.add_dependency(%q<rack>, [">= 1.0.0"])
      s.add_dependency(%q<rack-test>, [">= 0.3.0"])
    end
  else
    s.add_dependency(%q<sinatra>, [">= 0.10.1"])
    s.add_dependency(%q<maruku>, [">= 0.6.0"])
    s.add_dependency(%q<rack>, [">= 1.0.0"])
    s.add_dependency(%q<rack-test>, [">= 0.3.0"])
  end
end
