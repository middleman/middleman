require 'test_helper'

class TestGenerator < Test::Unit::TestCase
  def build_generator(testing_framework = :shoulda, options = {})
    options = options.merge :project_name => 'the-perfect-gem',
                            :user_name => 'John Doe',
                            :user_email => 'john@example.com',
                            :github_username => 'johndoe',
                            :github_token => 'yyz',
                            :documentation_framework => :rdoc

    options[:testing_framework] = testing_framework
    Jeweler::Generator.new(options)
  end

  should "have the correct constant name" do
    assert_equal "ThePerfectGem", build_generator.constant_name
  end

  should "have the correct file name prefix" do
    assert_equal "the_perfect_gem", build_generator.file_name_prefix
  end

  should "have the correct require name" do
    assert_equal "the-perfect-gem", build_generator.require_name
  end

  should "have the correct lib file name" do
    assert_equal "the-perfect-gem.rb", build_generator.lib_filename
  end

  def self.should_have_generator_attribute(attribute, value)
    should "have #{value} for #{attribute}" do
      assert_equal value, build_generator(@framework).send(attribute)
    end
  end

  context "shoulda" do
    setup { @framework = :shoulda }
    should_have_generator_attribute :test_task, 'test'
    should_have_generator_attribute :test_dir, 'test'
    should_have_generator_attribute :default_task, 'test'
    should_have_generator_attribute :feature_support_require, 'test/unit/assertions'
    should_have_generator_attribute :feature_support_extend, 'Test::Unit::Assertions'
    should_have_generator_attribute :test_pattern, 'test/**/test_*.rb'
    should_have_generator_attribute :test_filename, 'test_the-perfect-gem.rb'
    should_have_generator_attribute :test_helper_filename, 'helper.rb'
  end

  context "testunit" do
    setup { @framework = :testunit }
    should_have_generator_attribute :test_task, 'test'
    should_have_generator_attribute :test_dir, 'test'
    should_have_generator_attribute :default_task, 'test'
    should_have_generator_attribute :feature_support_require, 'test/unit/assertions'
    should_have_generator_attribute :feature_support_extend, 'Test::Unit::Assertions'
    should_have_generator_attribute :test_pattern, 'test/**/test_*.rb'
    should_have_generator_attribute :test_filename, 'test_the-perfect-gem.rb'
    should_have_generator_attribute :test_helper_filename, 'helper.rb'
  end

  context "minitest" do
    setup { @framework = :minitest }
    should_have_generator_attribute :test_task, 'test'
    should_have_generator_attribute :test_dir, 'test'
    should_have_generator_attribute :default_task, 'test'
    should_have_generator_attribute :feature_support_require, 'minitest/unit'
    should_have_generator_attribute :feature_support_extend, 'MiniTest::Assertions'
    should_have_generator_attribute :test_pattern, 'test/**/test_*.rb'
    should_have_generator_attribute :test_filename, 'test_the-perfect-gem.rb'
    should_have_generator_attribute :test_helper_filename, 'helper.rb'
  end

  context "bacon" do
    setup { @framework = :bacon }
    should_have_generator_attribute :test_task, 'spec'
    should_have_generator_attribute :test_dir, 'spec'
    should_have_generator_attribute :default_task, 'spec'
    should_have_generator_attribute :feature_support_require, 'test/unit/assertions'
    should_have_generator_attribute :feature_support_extend, 'Test::Unit::Assertions'
    should_have_generator_attribute :test_pattern, 'spec/**/*_spec.rb'
    should_have_generator_attribute :test_filename, 'the-perfect-gem_spec.rb'
    should_have_generator_attribute :test_helper_filename, 'spec_helper.rb'
  end

  context "rspec" do
    setup { @framework = :rspec }
    should_have_generator_attribute :test_task, 'spec'
    should_have_generator_attribute :test_dir, 'spec'
    should_have_generator_attribute :default_task, 'spec'
    should_have_generator_attribute :feature_support_require, 'spec/expectations'
    should_have_generator_attribute :feature_support_extend, nil
    should_have_generator_attribute :test_pattern, 'spec/**/*_spec.rb'
    should_have_generator_attribute :test_filename, 'the-perfect-gem_spec.rb'
    should_have_generator_attribute :test_helper_filename, 'spec_helper.rb'
  end

  context "micronaut" do
    setup { @framework = :micronaut }
    should_have_generator_attribute :test_task, 'examples'
    should_have_generator_attribute :test_dir, 'examples'
    should_have_generator_attribute :default_task, 'examples'
    should_have_generator_attribute :feature_support_require, 'micronaut/expectations'
    should_have_generator_attribute :feature_support_extend, 'Micronaut::Matchers'
    should_have_generator_attribute :test_pattern, 'examples/**/*_example.rb'
    should_have_generator_attribute :test_filename, 'the-perfect-gem_example.rb'
    should_have_generator_attribute :test_helper_filename, 'example_helper.rb'
  end
  
  context "testspec" do
    setup { @framework = :testspec }
    should_have_generator_attribute :test_task, 'test'
    should_have_generator_attribute :test_dir, 'test'
    should_have_generator_attribute :default_task, 'test'
    should_have_generator_attribute :feature_support_require, 'test/unit/assertions'
    should_have_generator_attribute :feature_support_extend, 'Test::Unit::Assertions'
    should_have_generator_attribute :test_pattern, 'test/**/*_test.rb'
    should_have_generator_attribute :test_filename, 'the-perfect-gem_test.rb'
    should_have_generator_attribute :test_helper_filename, 'test_helper.rb'
  end
  
end
