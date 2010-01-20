# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{httpclient}
  s.version = "2.1.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["NAKAMURA, Hiroshi"]
  s.date = %q{2009-06-24}
  s.email = %q{nahi@ruby-lang.org}
  s.files = ["lib/tags", "lib/http-access2", "lib/http-access2/http.rb", "lib/http-access2/cookie.rb", "lib/httpclient", "lib/httpclient/connection.rb", "lib/httpclient/cacert_sha1.p7s", "lib/httpclient/http.rb", "lib/httpclient/auth.rb", "lib/httpclient/util.rb", "lib/httpclient/session.rb", "lib/httpclient/ssl_config.rb", "lib/httpclient/timeout.rb", "lib/httpclient/cookie.rb", "lib/httpclient/cacert.p7s", "lib/httpclient.rb", "lib/http-access2.rb"]
  s.homepage = %q{http://dev.ctor.org/httpclient}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{gives something like the functionality of libwww-perl (LWP) in Ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
