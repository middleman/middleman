require File.expand_path(File.dirname(__FILE__) + '/helper')

describe "ObjectSpace" do
  def setup
  end

  def teardown
  end

  context "#classes" do
    should "take an snapshot of the current loaded classes" do
      snapshot = ObjectSpace.classes
      assert_equal snapshot.include?(Padrino::Logger), true
    end

    should "return a Set object" do
      snapshot = ObjectSpace.classes
      assert_equal snapshot.kind_of?(Set), true
    end

    should "be able to process a the class name given a block" do
      klasses = ObjectSpace.classes do |klass|
        if klass.name =~ /^Padrino::/
          klass
        end
      end

      assert_equal (klasses.size > 1), true
      klasses.each do |klass|
        assert_match /^Padrino::/, klass.to_s
      end
    end
  end

  context "#new_classes" do
    setup do
      @snapshot = ObjectSpace.classes
    end

    should "return list of new classes" do
      class OSTest; end
      module OSTestModule; class B; end; end

      new_classes = ObjectSpace.new_classes(@snapshot)

      assert_equal new_classes.size, 2
      assert_equal new_classes.include?(OSTest), true
      assert_equal new_classes.include?(OSTestModule::B), true
    end

    should "return a Set object" do
      new_classes = ObjectSpace.new_classes(@snapshot)
      assert_equal new_classes.kind_of?(Set), true
    end
  end
end
