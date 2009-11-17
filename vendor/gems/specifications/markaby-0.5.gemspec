# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{markaby}
  s.version = "0.5"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Fletcher and _why"]
  s.cert_chain = nil
  s.date = %q{2006-10-02}
  s.extra_rdoc_files = ["README"]
  s.files = ["README", "Rakefile", "setup.rb", "test/test_markaby.rb", "lib/markaby", "lib/markaby.rb", "lib/markaby/metaid.rb", "lib/markaby/tags.rb", "lib/markaby/builder.rb", "lib/markaby/cssproxy.rb", "lib/markaby/rails.rb", "lib/markaby/template.rb", "tools/rakehelp.rb"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Markup as Ruby, write HTML in your native Ruby tongue}
  s.test_files = ["test/test_markaby.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 1

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<builder>, [">= 2.0.0"])
    else
      s.add_dependency(%q<builder>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<builder>, [">= 2.0.0"])
  end
end
