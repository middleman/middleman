# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{git}
  s.version = "1.2.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Chacon"]
  s.date = %q{2009-10-16}
  s.email = %q{schacon@gmail.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["lib/git.rb", "lib/git/author.rb", "lib/git/base.rb", "lib/git/branch.rb", "lib/git/branches.rb", "lib/git/diff.rb", "lib/git/index.rb", "lib/git/lib.rb", "lib/git/log.rb", "lib/git/object.rb", "lib/git/path.rb", "lib/git/remote.rb", "lib/git/repository.rb", "lib/git/stash.rb", "lib/git/stashes.rb", "lib/git/status.rb", "lib/git/working_directory.rb", "README"]
  s.homepage = %q{http://github.com/schacon/ruby-git}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.requirements = ["git 1.6.0.0, or greater"]
  s.rubyforge_project = %q{git}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Ruby/Git is a Ruby library that can be used to create, read and manipulate Git repositories by wrapping system calls to the git binary}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
