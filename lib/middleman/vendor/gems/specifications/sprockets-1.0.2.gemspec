# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sprockets}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sam Stephenson"]
  s.date = %q{2009-02-23}
  s.default_executable = %q{sprocketize}
  s.description = %q{Sprockets is a Ruby library that preprocesses and concatenates JavaScript source files.}
  s.email = %q{sstephenson@gmail.com}
  s.executables = ["sprocketize"]
  s.files = ["Rakefile", "bin/sprocketize", "lib/sprockets", "lib/sprockets/concatenation.rb", "lib/sprockets/environment.rb", "lib/sprockets/error.rb", "lib/sprockets/pathname.rb", "lib/sprockets/preprocessor.rb", "lib/sprockets/secretary.rb", "lib/sprockets/source_file.rb", "lib/sprockets/source_line.rb", "lib/sprockets/version.rb", "lib/sprockets.rb", "test/fixtures", "test/fixtures/assets", "test/fixtures/assets/images", "test/fixtures/assets/images/script_with_assets", "test/fixtures/assets/images/script_with_assets/one.png", "test/fixtures/assets/images/script_with_assets/two.png", "test/fixtures/assets/stylesheets", "test/fixtures/assets/stylesheets/script_with_assets.css", "test/fixtures/constants.yml", "test/fixtures/double_slash_comments_that_are_not_requires_should_be_ignored_when_strip_comments_is_false.js", "test/fixtures/double_slash_comments_that_are_not_requires_should_be_removed_by_default.js", "test/fixtures/multiline_comments_should_be_removed_by_default.js", "test/fixtures/requiring_a_file_after_it_has_already_been_required_should_do_nothing.js", "test/fixtures/requiring_a_file_that_does_not_exist_should_raise_an_error.js", "test/fixtures/requiring_a_single_file_should_replace_the_require_comment_with_the_file_contents.js", "test/fixtures/requiring_the_current_file_should_do_nothing.js", "test/fixtures/src", "test/fixtures/src/constants.yml", "test/fixtures/src/foo", "test/fixtures/src/foo/bar.js", "test/fixtures/src/foo/foo.js", "test/fixtures/src/foo.js", "test/fixtures/src/script_with_assets.js", "test/test_concatenation.rb", "test/test_environment.rb", "test/test_helper.rb", "test/test_pathname.rb", "test/test_preprocessor.rb", "test/test_secretary.rb", "test/test_source_file.rb", "test/test_source_line.rb", "ext/nph-sprockets.cgi"]
  s.homepage = %q{http://getsprockets.org/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{sprockets}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{JavaScript dependency management and concatenation}
  s.test_files = ["test/test_concatenation.rb", "test/test_environment.rb", "test/test_helper.rb", "test/test_pathname.rb", "test/test_preprocessor.rb", "test/test_secretary.rb", "test/test_source_file.rb", "test/test_source_line.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
