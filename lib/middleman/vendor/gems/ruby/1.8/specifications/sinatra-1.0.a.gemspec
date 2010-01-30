# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sinatra}
  s.version = "1.0.a"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Blake Mizerany", "Ryan Tomayko", "Simon Rozet"]
  s.date = %q{2010-01-28}
  s.description = %q{Classy web-development dressed in a DSL}
  s.email = %q{sinatrarb@googlegroups.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["AUTHORS", "CHANGES", "LICENSE", "README.jp.rdoc", "README.rdoc", "Rakefile", "lib/sinatra.rb", "lib/sinatra/base.rb", "lib/sinatra/images/404.png", "lib/sinatra/images/500.png", "lib/sinatra/main.rb", "lib/sinatra/showexceptions.rb", "lib/sinatra/tilt.rb", "sinatra.gemspec", "test/base_test.rb", "test/builder_test.rb", "test/contest.rb", "test/erb_test.rb", "test/erubis_test.rb", "test/extensions_test.rb", "test/filter_test.rb", "test/haml_test.rb", "test/helper.rb", "test/helpers_test.rb", "test/mapped_error_test.rb", "test/middleware_test.rb", "test/public/favicon.ico", "test/request_test.rb", "test/response_test.rb", "test/result_test.rb", "test/route_added_hook_test.rb", "test/routing_test.rb", "test/sass_test.rb", "test/server_test.rb", "test/settings_test.rb", "test/sinatra_test.rb", "test/static_test.rb", "test/templates_test.rb", "test/views/error.builder", "test/views/error.erb", "test/views/error.erubis", "test/views/error.haml", "test/views/error.sass", "test/views/foo/hello.test", "test/views/hello.builder", "test/views/hello.erb", "test/views/hello.erubis", "test/views/hello.haml", "test/views/hello.sass", "test/views/hello.test", "test/views/layout2.builder", "test/views/layout2.erb", "test/views/layout2.erubis", "test/views/layout2.haml", "test/views/layout2.test"]
  s.homepage = %q{http://sinatra.rubyforge.org}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Sinatra", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{sinatra}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Classy web-development dressed in a DSL}
  s.test_files = ["test/base_test.rb", "test/builder_test.rb", "test/erb_test.rb", "test/erubis_test.rb", "test/extensions_test.rb", "test/filter_test.rb", "test/haml_test.rb", "test/helpers_test.rb", "test/mapped_error_test.rb", "test/middleware_test.rb", "test/request_test.rb", "test/response_test.rb", "test/result_test.rb", "test/route_added_hook_test.rb", "test/routing_test.rb", "test/sass_test.rb", "test/server_test.rb", "test/settings_test.rb", "test/sinatra_test.rb", "test/static_test.rb", "test/templates_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.0"])
      s.add_development_dependency(%q<shotgun>, [">= 0.6", "< 1.0"])
      s.add_development_dependency(%q<rack-test>, [">= 0.3.0"])
      s.add_development_dependency(%q<haml>, [">= 0"])
      s.add_development_dependency(%q<builder>, [">= 0"])
      s.add_development_dependency(%q<erubis>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 1.0"])
      s.add_dependency(%q<shotgun>, [">= 0.6", "< 1.0"])
      s.add_dependency(%q<rack-test>, [">= 0.3.0"])
      s.add_dependency(%q<haml>, [">= 0"])
      s.add_dependency(%q<builder>, [">= 0"])
      s.add_dependency(%q<erubis>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.0"])
    s.add_dependency(%q<shotgun>, [">= 0.6", "< 1.0"])
    s.add_dependency(%q<rack-test>, [">= 0.3.0"])
    s.add_dependency(%q<haml>, [">= 0"])
    s.add_dependency(%q<builder>, [">= 0"])
    s.add_dependency(%q<erubis>, [">= 0"])
  end
end
