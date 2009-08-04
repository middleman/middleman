# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{middleman}
  s.version = "0.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas Reynolds"]
  s.date = %q{2009-08-04}
  s.email = %q{tdreyno@gmail.com}
  s.executables = ["mm-init", "mm-build", "mm-server"]
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
     "lib/middleman/helpers.rb",
     "lib/middleman/template/init.rb",
     "lib/middleman/template/views/index.haml",
     "lib/middleman/template/views/layout.haml",
     "lib/middleman/template/views/stylesheets/site.sass",
     "middleman.gemspec",
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
     "spec/spec_helper.rb",
     "vendor/rack-test/History.txt",
     "vendor/rack-test/MIT-LICENSE.txt",
     "vendor/rack-test/README.rdoc",
     "vendor/rack-test/Rakefile",
     "vendor/rack-test/lib/rack/mock_session.rb",
     "vendor/rack-test/lib/rack/test.rb",
     "vendor/rack-test/lib/rack/test/cookie_jar.rb",
     "vendor/rack-test/lib/rack/test/methods.rb",
     "vendor/rack-test/lib/rack/test/mock_digest_request.rb",
     "vendor/rack-test/lib/rack/test/uploaded_file.rb",
     "vendor/rack-test/lib/rack/test/utils.rb",
     "vendor/rack-test/spec/fixtures/config.ru",
     "vendor/rack-test/spec/fixtures/fake_app.rb",
     "vendor/rack-test/spec/fixtures/foo.txt",
     "vendor/rack-test/spec/rack/test/cookie_spec.rb",
     "vendor/rack-test/spec/rack/test/digest_auth_spec.rb",
     "vendor/rack-test/spec/rack/test/multipart_spec.rb",
     "vendor/rack-test/spec/rack/test/utils_spec.rb",
     "vendor/rack-test/spec/rack/test_spec.rb",
     "vendor/rack-test/spec/rcov.opts",
     "vendor/rack-test/spec/spec.opts",
     "vendor/rack-test/spec/spec_helper.rb",
     "vendor/sinatra-content-for/LICENSE",
     "vendor/sinatra-content-for/README.rdoc",
     "vendor/sinatra-content-for/Rakefile",
     "vendor/sinatra-content-for/lib/sinatra/content_for.rb",
     "vendor/sinatra-content-for/sinatra-content-for.gemspec",
     "vendor/sinatra-content-for/test/content_for_test.rb",
     "vendor/sinatra-helpers/LICENSE",
     "vendor/sinatra-helpers/README.rdoc",
     "vendor/sinatra-helpers/Rakefile",
     "vendor/sinatra-helpers/VERSION.yml",
     "vendor/sinatra-helpers/lib/sinatra-helpers.rb",
     "vendor/sinatra-helpers/lib/sinatra-helpers/haml.rb",
     "vendor/sinatra-helpers/lib/sinatra-helpers/haml/flash.rb",
     "vendor/sinatra-helpers/lib/sinatra-helpers/haml/forms.rb",
     "vendor/sinatra-helpers/lib/sinatra-helpers/haml/links.rb",
     "vendor/sinatra-helpers/lib/sinatra-helpers/haml/partials.rb",
     "vendor/sinatra-helpers/lib/sinatra-helpers/html.rb",
     "vendor/sinatra-helpers/lib/sinatra-helpers/html/escape.rb",
     "vendor/sinatra-helpers/sinatra-helpers.gemspec",
     "vendor/sinatra-helpers/test/haml/flash_test.rb",
     "vendor/sinatra-helpers/test/haml/forms_test.rb",
     "vendor/sinatra-helpers/test/haml/links_test.rb",
     "vendor/sinatra-helpers/test/haml/partials_test.rb",
     "vendor/sinatra-helpers/test/haml/views/_object.haml",
     "vendor/sinatra-helpers/test/haml/views/_thing.haml",
     "vendor/sinatra-helpers/test/html/escape_test.rb",
     "vendor/sinatra-helpers/test/test_helper.rb",
     "vendor/sinatra-markaby/CHANGES",
     "vendor/sinatra-markaby/LICENSE",
     "vendor/sinatra-markaby/README.rdoc",
     "vendor/sinatra-markaby/Rakefile",
     "vendor/sinatra-markaby/TODO",
     "vendor/sinatra-markaby/VERSION.yml",
     "vendor/sinatra-markaby/lib/sinatra/markaby.rb",
     "vendor/sinatra-markaby/sinatra-markaby.gemspec",
     "vendor/sinatra-markaby/test/sinatra_markaby_test.rb",
     "vendor/sinatra-markaby/test/test_helper.rb",
     "vendor/sinatra-markaby/test/views/hello.mab",
     "vendor/sinatra-markaby/test/views/html.mab",
     "vendor/sinatra-maruku/LICENSE",
     "vendor/sinatra-maruku/README.markdown",
     "vendor/sinatra-maruku/Rakefile",
     "vendor/sinatra-maruku/VERSION.yml",
     "vendor/sinatra-maruku/examples/app.rb",
     "vendor/sinatra-maruku/examples/config.ru",
     "vendor/sinatra-maruku/examples/mapp.rb",
     "vendor/sinatra-maruku/examples/public/javascripts/application.js",
     "vendor/sinatra-maruku/examples/public/stylesheets/application.css",
     "vendor/sinatra-maruku/examples/public/stylesheets/print.css",
     "vendor/sinatra-maruku/examples/views/index.maruku",
     "vendor/sinatra-maruku/examples/views/layout.maruku",
     "vendor/sinatra-maruku/lib/sinatra/maruku.rb",
     "vendor/sinatra-maruku/sinatra-maruku.gemspec",
     "vendor/sinatra-maruku/test/sinatra_maruku_test.rb",
     "vendor/sinatra-maruku/test/test_helper.rb",
     "vendor/sinatra-maruku/test/views/hello.maruku",
     "vendor/sinatra-maruku/test/views/layout2.maruku"
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
