Feature: define wrapped matcher

  In order to reuse existing matchers
  As an RSpec user
  I want to define matchers that wrap other matchers
  
  Scenario: one additional method
    Given a file named "new_model_spec.rb" with:
      """
      Spec::Matchers.define :have_tag do |tag|
        match do |markup|
          markup =~ /<#{tag}>.*<\/#{tag}>/
        end
      end
      
      Spec::Matchers.define :have_button do
        match do |markup|
          markup.should have_tag('button')
        end
      end
      
      describe "some markup" do
        it "has a button" do
          "<button>Label</button>".should have_button
        end
      end
      """
    When I run "spec new_model_spec.rb --format specdoc"
    Then the stdout should include "1 example, 0 failures"
