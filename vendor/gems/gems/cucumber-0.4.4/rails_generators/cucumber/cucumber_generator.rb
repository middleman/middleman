require 'rbconfig'
require 'cucumber/platform'

# This generator bootstraps a Rails project for use with Cucumber
class CucumberGenerator < Rails::Generator::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  attr_accessor :framework

  def manifest
    record do |m|
      m.directory 'features/step_definitions'
      m.template 'webrat_steps.rb', 'features/step_definitions/webrat_steps.rb'
      m.template'cucumber_environment.rb', 'config/environments/cucumber.rb',
        :assigns => { :cucumber_version => ::Cucumber::VERSION }

      m.gsub_file 'config/database.yml', /test:.*\n/, "test: &TEST\n"
      unless File.read('config/database.yml').include? 'cucumber:'
        m.gsub_file 'config/database.yml', /\z/, "\ncucumber:\n  <<: *TEST"
      end

      m.directory 'features/support'
      if spork?
        m.template'spork_env.rb', 'features/support/env.rb'
      else
        m.template 'env.rb', 'features/support/env.rb'
      end
      m.template 'paths.rb', 'features/support/paths.rb'
      m.template 'version_check.rb', 'features/support/version_check.rb'

      m.directory 'lib/tasks'
      m.template'cucumber.rake', 'lib/tasks/cucumber.rake'

      m.file 'cucumber', 'script/cucumber', {
        :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang]
      }
    end
  end

  def framework
    options[:framework] ||= detect_default_framework!
  end

  def spork?
    options[:spork]
  end

protected

  def detect_default_framework!
    require 'rubygems'
    rspec! || testunit!
    raise "I don't know what test framework you want. Use --rspec or --testunit, or gem install rspec or test-unit." unless @default_framework
    @default_framework
  end

  def rspec!
    begin
      require 'spec'
      @default_framework = :rspec
    rescue LoadError
      false
    end
  end

  def testunit!
    begin
      require 'test/unit'
      @default_framework = :testunit
    rescue LoadError
      false
    end
  end

  def banner
    "Usage: #{$0} cucumber"
  end

  def after_generate
    require 'cucumber/formatter/ansicolor'
    extend Cucumber::Formatter::ANSIColor

    if @default_framework
      puts <<-WARNING

#{yellow_cukes(15)} 

          #{yellow_cukes(1)}   T E S T   F R A M E W O R K   A L E R T    #{yellow_cukes(1)}

You didn't explicitly generate with --rspec or --testunit, so I looked at
your gems and saw that you had #{green(@default_framework.to_s)} installed, so I went with that. 
If you want something else, be specific about it. Otherwise, relax.

#{yellow_cukes(15)} 

WARNING
    end
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on('--rspec', "Setup cucumber for use with RSpec") do |value|
      options[:framework] = :rspec
    end

    opt.on('--testunit', "Setup cucumber for use with test/unit") do |value|
      options[:framework] = :testunit
    end

    opt.on('--spork', 'Setup cucumber for use with Spork') do |value|
      options[:spork] = true
    end
  end

end
