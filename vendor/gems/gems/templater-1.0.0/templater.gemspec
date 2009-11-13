# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{templater}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonas Nicklas"]
  s.date = %q{2009-08-28}
  s.description = %q{Templater has the ability to both copy files from A to B and also to render templates using ERB. Templater consists of four parts:

- Actions (File copying routines, templates generation and directories creation routines).
- Generators (set of rules).
- Manifolds (generator suites).
- The command line interface.

Hierarchy is pretty simple: manifold has one or many public and private generators. Public ones are supposed to be called
by end user. Generators have one or more action that specify what they do, where they take files, how they name resulting
files and so forth.}
  s.email = ["jonas.nicklas@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "lib/templater.rb", "lib/templater/actions/action.rb", "lib/templater/actions/directory.rb", "lib/templater/actions/empty_directory.rb", "lib/templater/actions/file.rb", "lib/templater/actions/template.rb", "lib/templater/capture_helpers.rb", "lib/templater/cli/generator.rb", "lib/templater/cli/manifold.rb", "lib/templater/cli/parser.rb", "lib/templater/core_ext/kernel.rb", "lib/templater/core_ext/string.rb", "lib/templater/description.rb", "lib/templater/discovery.rb", "lib/templater/generator.rb", "lib/templater/manifold.rb", "lib/templater/spec/helpers.rb", "script/console", "script/destroy", "script/generate", "spec/actions/directory_spec.rb", "spec/actions/empty_directory_spec.rb", "spec/actions/file_spec.rb", "spec/actions/template_spec.rb", "spec/core_ext/string_spec.rb", "spec/generator/actions_spec.rb", "spec/generator/arguments_spec.rb", "spec/generator/desc_spec.rb", "spec/generator/destination_root_spec.rb", "spec/generator/empty_directories_spec.rb", "spec/generator/files_spec.rb", "spec/generator/generators_spec.rb", "spec/generator/glob_spec.rb", "spec/generator/invocations_spec.rb", "spec/generator/invoke_spec.rb", "spec/generator/options_spec.rb", "spec/generator/render_spec.rb", "spec/generator/source_root_spec.rb", "spec/generator/templates_spec.rb", "spec/manifold_spec.rb", "spec/options_parser_spec.rb", "spec/results/erb.rbs", "spec/results/file.rbs", "spec/results/random.rbs", "spec/results/simple_erb.rbs", "spec/spec_helper.rb", "spec/spec_helpers_spec.rb", "spec/templater_spec.rb", "spec/templates/erb.rbt", "spec/templates/glob/README", "spec/templates/glob/arg.js", "spec/templates/glob/hellothar.%feh%", "spec/templates/glob/hellothar.html.%feh%", "spec/templates/glob/subfolder/jessica_alba.jpg", "spec/templates/glob/subfolder/monkey.rb", "spec/templates/glob/test.rb", "spec/templates/literals_erb.rbt", "spec/templates/simple.rbt", "spec/templates/simple_erb.rbt", "templater.gemspec"]
  s.homepage = %q{http://github.com/jnicklas/templater}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{templater}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Templater has the ability to both copy files from A to B and also to render templates using ERB}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<highline>, [">= 1.4.0"])
      s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
      s.add_runtime_dependency(%q<extlib>, [">= 0.9.5"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.8"])
      s.add_development_dependency(%q<hoe>, [">= 2.3.3"])
    else
      s.add_dependency(%q<highline>, [">= 1.4.0"])
      s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
      s.add_dependency(%q<extlib>, [">= 0.9.5"])
      s.add_dependency(%q<rspec>, [">= 1.2.8"])
      s.add_dependency(%q<hoe>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<highline>, [">= 1.4.0"])
    s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
    s.add_dependency(%q<extlib>, [">= 0.9.5"])
    s.add_dependency(%q<rspec>, [">= 1.2.8"])
    s.add_dependency(%q<hoe>, [">= 2.3.3"])
  end
end
