# Jeweler: Craft the perfect RubyGem

Jeweler provides two things:

 * Rake tasks for managing gems and versioning of a <a href="http://github.com">GitHub</a> project
 * A generator for creating kickstarting a new project

## Quick Links

 * [Wiki](http://wiki.github.com/technicalpickles/jeweler)
 * [Bugs](http://github.com/technicalpickles/jeweler/issues)
 * [Donate](http://pledgie.org/campaigns/2604)

## Installing

    # Install the gem:
    sudo gem install jeweler
    
## Using in an existing project

It's easy to get up and running. Update your Rakefile to instantiate a `Jeweler::Tasks`, and give it a block with details about your project.

    begin
      require 'jeweler'
      Jeweler::Tasks.new do |gemspec|
        gemspec.name = "the-perfect-gem"
        gemspec.summary = "Summarize your gem"
        gemspec.description = "Describe your gem"
        gemspec.email = "josh@technicalpickles.com"
        gemspec.homepage = "http://github.com/technicalpickles/the-perfect-gem"
        gemspec.description = "TODO"
        gemspec.authors = ["Josh Nichols"]
      end
    rescue LoadError
      puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
    end

The yield object here, `gemspec`, is a `Gem::Specification` object. See the [Customizing your project's gem specification](http://wiki.github.com/technicalpickles/jeweler/customizing-your-projects-gem-specification) for more details about how you can customize your gemspec.

## Using to start a new project

Jeweler provides a generator. It requires you to [setup your name and email for git](http://help.github.com/git-email-settings/) and [your username and token for GitHub](http://github.com/guides/local-github-config).

    jeweler the-perfect-gem

This will prepare a project in the 'the-perfect-gem' directory, setup to use Jeweler.

It supports a number of options:

 * --create-repo: in addition to preparing a project, it create an repo up on GitHub and enable RubyGem generation
 * --testunit: generate test_helper.rb and test ready for test/unit
 * --minitest: generate test_helper.rb and test ready for minitest 
 * --shoulda: generate test_helper.rb and test ready for shoulda (this is the default)
 * --rspec: generate spec_helper.rb and spec ready for rspec
 * --bacon: generate spec_helper.rb and spec ready for bacon
 * --gemcutter: setup releasing to gemcutter
 * --rubyforge: setup releasing to rubyforge

### Default options

Jeweler respects the JEWELER_OPTS environment variable. Want to always use RSpec, and you're using bash? Add this to ~/.bashrc:

    export JEWELER_OPTS="--rspec"

## Gemspec

Jeweler handles generating a gemspec file for your project:

    rake gemspec

This creates a gemspec for your project. It's based on the info you give `Jeweler::Tasks`, the current version of your project, and some defaults that Jeweler provides.

## Gem

Jeweler gives you tasks for building and installing your gem:

    rake build
    rake install

## Versioning

Jeweler tracks the version of your project. It assumes you will be using a version in the format `x.y.z`. `x` is the 'major' version, `y` is the 'minor' version, and `z` is the patch version.

Initially, your project starts out at 0.0.0. Jeweler provides Rake tasks for bumping the version:

    rake version:bump:major
    rake version:bump:minor
    rake version:bump:patch

## Releasing to GitHub

Jeweler handles releasing your gem into the wild:

    rake release

It does the following for you:

 * Regenerate the gemspec to the latest version of your project
 * Push to GitHub (which results in a gem being build)
 * Tag the version and push to GitHub

## Releasing to Gemcutter

Jeweler can also handle releasing to [Gemcutter](http://gemcutter.org). There are a few steps you need to do before doing any Gemcutter releases with Jeweler:

 * [Create an account on Gemcutter](http://gemcutter.org/sign_up)
 * Install the Gemcutter gem: sudo gem install gemcutter
 * Run 'gemcutter tumble' to set up RubyGems to use gemcutter as the default source
 * Update your Rakefile to make an instance of `Jeweler::GemcutterTasks`


A Rakefile setup for gemcutter would include something like this:

    begin
      require 'jeweler'
      Jeweler::Tasks.new do |gem|
        # ommitted for brevity
      end
      Jeweler::GemcutterTasks.new
    rescue LoadError
      puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
    end


With all that setup out of the way, you can now release to Gemcutter with impunity. This would release the current version of your gem.

    $ rake gemcutter:release

## Releasing to RubyForge

Jeweler can also handle releasing to [RubyForge](http://rubyforge.org). There are a few steps you need to do before doing any RubyForge releases with Jeweler:

 * [Create an account on RubyForge](http://rubyforge.org/account/register.php)
 * Request a project on RubyForge.
 * Install the RubyForge gem: sudo gem install rubyforge
 * Run 'rubyforge setup' and fill in your username and password for RubyForge
 * Run 'rubyforge config' to pull down information about your projects
 * Run 'rubyforge login' to make sure you are able to login
 * In Jeweler::Tasks, you must set `rubyforge_project` to the project you just created
 * Add Jeweler::RubyforgeTasks to bring in the appropriate tasks.
 * Note, using `jeweler --rubyforge` when generating the project does this for you automatically.

A Rakefile setup for rubyforge would include something like this:

    begin
      require 'jeweler'
      Jeweler::Tasks.new do |s|
        # ommitted for brevity
        s.rubyforge_project = 'the-perfect-gem' # This line would be new
      end

      Jeweler::RubyforgeTasks.new do |rubyforge|
        rubyforge.doc_task = "rdoc"
      end
    rescue LoadError
      puts "Jeweler, or a dependency, not available. Install it with: sudo gem install jeweler"
    end

Now you must initially create a 'package' for your gem in your RubyForge 'project':

    $ rake rubyforge:setup

With all that setup out of the way, you can now release to RubyForge with impunity. This would release the current version of your gem, and upload the rdoc as your project's webpage.

    $ rake rubyforge:release

## Release Workflow

 * Hack, commit, hack, commit, etc, etc
 * `rake version:bump:patch release` to do the actual version bump and release
 * Have a delicious scotch
 * Install [gemstalker](http://github.com/technicalpickles/gemstalker), and use it to know when gem is built. It typically builds in a few minutes, but won't be installable for another 15 minutes.

