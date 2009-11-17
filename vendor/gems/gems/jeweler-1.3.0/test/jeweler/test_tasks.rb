require 'test_helper'

require 'rake'
class TestTasks < Test::Unit::TestCase
  include Rake

  context 'instantiating Jeweler::Tasks' do
    setup do
      @gemspec_building_block = lambda {}
      @tasks = Jeweler::Tasks.new &@gemspec_building_block
    end

    teardown do
      Task.clear
    end

    should 'assign @gemspec' do
      assert_not_nil @tasks.gemspec
    end

    should 'not eagerly initialize Jeweler' do
      assert ! @tasks.instance_variable_defined?(:@jeweler)
    end

    should 'set self as the application-wide jeweler tasks' do
      assert_same @tasks, Rake.application.jeweler_tasks
    end

    should 'save gemspec building block for later' do
      assert_same @gemspec_building_block, @tasks.gemspec_building_block
    end

    context 'Jeweler instance' do
      setup do
        @tasks.jeweler
      end

      should 'initailize Jeweler' do
        assert @tasks.instance_variable_defined?(:@jeweler)
      end
    end

    should 'yield the gemspec instance' do
      spec = nil
      @tasks = Jeweler::Tasks.new { |s| spec = s }
      assert_not_nil @tasks.jeweler.gemspec
    end

  end
end
