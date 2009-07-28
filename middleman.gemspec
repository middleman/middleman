# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{middleman}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas Reynolds"]
  s.date = %q{2009-07-28}
  s.email = %q{tdreyno@gmail.com}
  s.executables = ["sm-init", "sm-build", "sm-server"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     ".gitmodules",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/mm-build",
     "bin/mm-init",
     "bin/mm-server",
     "lib/middleman.rb",
     "lib/middleman/template/views/index.haml",
     "lib/middleman/template/views/layout.haml",
     "lib/middleman/template/views/stylesheets/site.sass",
     "spec/builder_spec.rb",
     "spec/fixtures/sample/public/static.html",
     "spec/fixtures/sample/public/stylesheets/static.css",
     "spec/fixtures/sample/views/_partial.haml",
     "spec/fixtures/sample/views/index.haml",
     "spec/fixtures/sample/views/layout.haml",
     "spec/fixtures/sample/views/markaby.mab",
     "spec/fixtures/sample/views/maruku.maruku",
     "spec/fixtures/sample/views/services/index.haml",
     "spec/fixtures/sample/views/stylesheets/site.sass",
     "spec/generator_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/tdreyno/middleman}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{middleman}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A static site generator utilizing Haml and Sass}
  s.test_files = [
    "spec/builder_spec.rb",
     "spec/generator_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<templater>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0"])
      s.add_runtime_dependency(%q<markaby>, [">= 0"])
      s.add_runtime_dependency(%q<maruku>, [">= 0"])
      s.add_runtime_dependency(%q<haml>, [">= 2.1.0"])
      s.add_runtime_dependency(%q<chriseppstein-compass>, [">= 0"])
    else
      s.add_dependency(%q<templater>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<markaby>, [">= 0"])
      s.add_dependency(%q<maruku>, [">= 0"])
      s.add_dependency(%q<haml>, [">= 2.1.0"])
      s.add_dependency(%q<chriseppstein-compass>, [">= 0"])
    end
  else
    s.add_dependency(%q<templater>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<markaby>, [">= 0"])
    s.add_dependency(%q<maruku>, [">= 0"])
    s.add_dependency(%q<haml>, [">= 2.1.0"])
    s.add_dependency(%q<chriseppstein-compass>, [">= 0"])
  end
end
