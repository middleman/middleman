require 'test_helper'

class HookTest < MiniTest::Spec
  subject { Hooks::Hook.new({}) }

  it "exposes array behaviour for callbacks" do
    subject << :play_music
    subject << :drink_beer

    subject.to_a.must_equal [:play_music, :drink_beer]
  end
end

class ResultsTest < MiniTest::Spec
  subject { Hooks::Hook::Results.new }

  describe "#halted?" do
    it "defaults to false" do
      subject.halted?.must_equal false
    end

    it "responds to #halted!" do
      subject.halted!
      subject.halted?.must_equal true
    end

    it "responds to #not_halted?" do
      subject.not_halted?.must_equal true
    end
  end
end