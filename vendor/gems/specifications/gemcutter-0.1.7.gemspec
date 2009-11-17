# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gemcutter}
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Quaranto"]
  s.date = %q{2009-11-15}
  s.description = %q{Adds several commands for using gemcutter.org, such as pushing new gems, migrating gems from RubyForge, and more.}
  s.email = %q{nick@quaran.to}
  s.files = ["lib/commands/abstract_command.rb", "lib/commands/migrate.rb", "lib/commands/owner.rb", "lib/commands/push.rb", "lib/commands/tumble.rb", "lib/rubygems_plugin.rb", "test/command_helper.rb"]
  s.homepage = %q{http://github.com/qrush/gemcutter}
  s.post_install_message = %q{
========================================================================

           Thanks for installing Gemcutter! You can now run:

    gem tumble        use Gemcutter as your primary RubyGem source
    gem push          publish your gems for the world to use and enjoy
    gem migrate       take over your gem from RubyForge on Gemcutter
    gem owner         allow/disallow others to push to your gems

========================================================================

}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{gemcutter}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Commands to interact with gemcutter.org}
  s.test_files = ["test/command_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_runtime_dependency(%q<net-scp>, [">= 0"])
    else
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<net-scp>, [">= 0"])
    end
  else
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<net-scp>, [">= 0"])
  end
end
