# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'term-ansicolor'
  s.version = '1.0.4'
  s.summary = "Ruby library that colors strings using ANSI escape sequences"
  s.description = ""

  s.files = ["CHANGES", "COPYING", "README", "Rakefile", "VERSION", "examples", "examples/cdiff.rb", "examples/example.rb", "install.rb", "lib", "lib/term", "lib/term/ansicolor", "lib/term/ansicolor.rb", "lib/term/ansicolor/version.rb", "term-ansicolor.gemspec"]

  s.require_path = 'lib'

  s.has_rdoc = true
  s.extra_rdoc_files << 'doc-main.txt'
  s.rdoc_options << '--main' <<  'doc-main.txt'

  s.author = "Florian Frank"
  s.email = "flori@ping.de"
  s.homepage = "http://term-ansicolor.rubyforge.org"
  s.rubyforge_project = 'term-ansicolor'
end
