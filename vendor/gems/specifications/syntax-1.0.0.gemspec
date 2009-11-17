# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{syntax}
  s.version = "1.0.0"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["Jamis Buck"]
  s.autorequire = %q{syntax}
  s.cert_chain = nil
  s.date = %q{2005-06-18}
  s.email = %q{jamis@jamisbuck.org}
  s.files = ["data/ruby.css", "data/xml.css", "data/yaml.css", "lib/syntax", "lib/syntax.rb", "lib/syntax/common.rb", "lib/syntax/convertors", "lib/syntax/lang", "lib/syntax/version.rb", "lib/syntax/convertors/abstract.rb", "lib/syntax/convertors/html.rb", "lib/syntax/lang/ruby.rb", "lib/syntax/lang/xml.rb", "lib/syntax/lang/yaml.rb", "test/ALL-TESTS.rb", "test/syntax", "test/tc_syntax.rb", "test/syntax/tc_ruby.rb", "test/syntax/tc_xml.rb", "test/syntax/tc_yaml.rb", "test/syntax/tokenizer_testcase.rb"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Syntax is Ruby library for performing simple syntax highlighting.}
  s.test_files = ["test/ALL-TESTS.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 1

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
