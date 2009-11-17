Gem::Specification.new do |s|
  s.name = %q{net-scp}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamis Buck"]
  s.date = %q{2009-02-04}
  s.description = %q{A pure Ruby implementation of the SCP client protocol}
  s.email = %q{jamis@jamisbuck.org}
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "lib/net/scp/download.rb", "lib/net/scp/errors.rb", "lib/net/scp/upload.rb", "lib/net/scp/version.rb", "lib/net/scp.rb", "lib/uri/open-scp.rb", "lib/uri/scp.rb", "README.rdoc"]
  s.files = ["CHANGELOG.rdoc", "lib/net/scp/download.rb", "lib/net/scp/errors.rb", "lib/net/scp/upload.rb", "lib/net/scp/version.rb", "lib/net/scp.rb", "lib/uri/open-scp.rb", "lib/uri/scp.rb", "Rakefile", "README.rdoc", "setup.rb", "test/common.rb", "test/test_all.rb", "test/test_download.rb", "test/test_scp.rb", "test/test_upload.rb", "Manifest", "net-scp.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://net-ssh.rubyforge.org/scp}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Net-scp", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{net-ssh}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{A pure Ruby implementation of the SCP client protocol}
  s.test_files = ["test/test_all.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<net-ssh>, [">= 1.99.1"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
    else
      s.add_dependency(%q<net-ssh>, [">= 1.99.1"])
      s.add_dependency(%q<echoe>, [">= 0"])
    end
  else
    s.add_dependency(%q<net-ssh>, [">= 1.99.1"])
    s.add_dependency(%q<echoe>, [">= 0"])
  end
end
