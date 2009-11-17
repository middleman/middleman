require File.dirname(__FILE__) + '/../../spec_helper'
require 'cucumber/parser/natural_language'

module Cucumber
  module Parser
    describe Feature do
      before do
        @step_mother = StepMother.new
        @parser = NaturalLanguage.get(@step_mother, 'en').parser
      end

      after do
        NaturalLanguage.instance_variable_set(:@languages, nil) # So that new StepMothers can be created and have adverbs registered
      end

      def parse(text)
        feature = @parser.parse_or_fail(text)
      end

      def parse_file(file)
        FeatureFile.new(File.dirname(__FILE__) + "/../treetop_parser/" + file).parse(@step_mother, {})
      end

      def parse_example_file(file)
        FeatureFile.new(File.dirname(__FILE__) + "/../../../examples/" + file).parse(@step_mother, {})
      end

      describe "Comments" do
        it "should parse a file with only a one line comment" do
          parse(%{# My comment
Feature: hi
}).to_sexp.should ==
          [:feature, nil, "Feature: hi",
            [:comment, "# My comment\n"]]
        end

        it "should parse a file with only a multiline comment" do
          parse(%{# Hello
# World
Feature: hi
}).to_sexp.should ==
          [:feature, nil, "Feature: hi",
            [:comment, "# Hello\n# World\n"]]
        end

        it "should parse a file with no comments" do
          parse("Feature: hi\n").to_sexp.should ==
          [:feature, nil, "Feature: hi"]
        end

        it "should parse a file with only a multiline comment with newlines" do
          parse("# Hello\n\n# World\n").to_sexp.should == 
          [:feature, nil, "", 
            [:comment, "# Hello\n\n# World\n"]]
        end
        
        it "should not consume comments as part of a multiline name" do
          parse("Feature: hi\n Scenario: test\n\n#hello\n Scenario: another").to_sexp.should ==
            [:feature, nil, "Feature: hi", 
             [:scenario, 2, "Scenario:", "test"], 
             [:scenario, 5, "Scenario:", "another", 
              [:comment, "#hello\n "]]]
        end
      end

      describe "Tags" do
        it "should parse a file with tags on a feature" do
          parse("# My comment\n@hello @world Feature: hi\n").to_sexp.should ==
          [:feature, nil, "Feature: hi",
            [:comment, "# My comment\n"],
            [:tag, "@hello"],
            [:tag, "@world"]]
        end

        it "should not take the tags as part of a multiline name feature element" do
          parse("Feature: hi\n Scenario: test\n\n@hello Scenario: another").to_sexp.should ==
          [:feature, nil, "Feature: hi",
           [:scenario, 2, "Scenario:", "test"], 
           [:scenario, 4, "Scenario:", "another", 
             [:tag, "@hello"]]]
        end

        it "should parse a file with tags on a scenario" do
          parse(%{# FC
  @ft
Feature: hi

  @st1 @st2   
  Scenario: First
    Given Pepper

@st3 
   @st4    @ST5  @#^%&ST6**!
  Scenario: Second}).to_sexp.should ==
          [:feature, nil, "Feature: hi",
            [:comment, "# FC\n  "],
            [:tag, "@ft"],
            [:scenario, 6, 'Scenario:', 'First',
              [:tag, "@st1"], [:tag, "@st2"],
              [:step_invocation, 7, "Given", "Pepper"]
            ],
            [:scenario, 11, 'Scenario:', 'Second',
              [:tag, "@st3"], [:tag, "@st4"], [:tag, "@ST5"], [:tag, "@#^%&ST6**!"]]]
        end
      end
      
      describe "Background" do
        it "should have steps" do
          parse("Feature: Hi\nBackground:\nGiven I am a step\n").to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:background, 2, "Background:",
              [:step, 3, "Given", "I am a step"]]]
        end
        
        it "should allow multiline names" do
          parse(%{Feature: Hi
Background: It is my ambition to say 
            in ten sentences
            what others say 
            in a whole book.
Given I am a step}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:background, 2, "Background:", "It is my ambition to say\nin ten sentences\nwhat others say\nin a whole book.",
              [:step, 6, "Given", "I am a step"]]]
        end
      end

      describe "Scenarios" do
        it "can be empty" do
          parse("Feature: Hi\n\nScenario: Hello\n").to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario, 3, "Scenario:", "Hello"]]
        end

        it "should allow whitespace lines after the Scenario line" do
          parse(%{Feature: Foo

Scenario: bar

  Given baz})
        end
            
        it "should have steps" do
          parse("Feature: Hi\nScenario: Hello\nGiven I am a step\n").to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario, 2, "Scenario:", "Hello",
              [:step_invocation, 3, "Given", "I am a step"]]]
        end

        it "should have steps with inline table" do
          parse(%{Feature: Hi
Scenario: Hello
Given I have a table
|a|b|
}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario, 2, "Scenario:", "Hello",
              [:step_invocation, 3, "Given", "I have a table",
                [:table,
                  [:row, 4,
                    [:cell, "a"],
                    [:cell, "b"]]]]]]
        end

        it "should have steps with inline py_string" do
          parse(%{Feature: Hi
Scenario: Hello
Given I have a string


   """
  hello
  world
  """

}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario, 2, "Scenario:", "Hello",
              [:step_invocation, 3, "Given", "I have a string",
                [:py_string, "hello\nworld"]]]]
        end
        
        it "should allow multiline names" do
          parse(%{Feature: Hi
Scenario: It is my ambition to say
          in ten sentences
          what others say 
          in a whole book.
Given I am a step

}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario, 2, "Scenario:", "It is my ambition to say\nin ten sentences\nwhat others say\nin a whole book.",
              [:step_invocation, 6, "Given", "I am a step"]]]
        end

        it "should ignore gherkin keywords which are parts of other words in the name" do
          parse(%{Feature: Parser bug
Scenario: I have a Button
          Buttons are great
  Given I have it
}).to_sexp.should ==
            [:feature, nil, "Feature: Parser bug",
            [:scenario, 2, "Scenario:", "I have a Button\nButtons are great",
              [:step_invocation, 4, "Given", "I have it"]]]

        end
      end

      describe "Scenario Outlines" do
        it "can be empty" do
          parse(%{Feature: Hi
Scenario Outline: Hello
Given a <what> cucumber
Examples:
|what|
|green|
}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario_outline, "Scenario Outline:", "Hello",
              [:step, 3, "Given", "a <what> cucumber"],
              [:examples, "Examples:", "",
                [:table, 
                  [:row, 5,
                    [:cell, "what"]], 
                  [:row, 6,
                    [:cell, "green"]]]]]]
        end

        it "should have line numbered steps with inline table" do
          parse(%{Feature: Hi
Scenario Outline: Hello

Given I have a table

|<a>|<b>|
Examples:
|a|b|
|c|d|
}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario_outline, "Scenario Outline:", "Hello",
              [:step, 4, "Given", "I have a table",
                [:table, 
                  [:row, 6,
                    [:cell, "<a>"], 
                    [:cell, "<b>"]]]],
            [:examples, "Examples:", "",
              [:table,
                [:row, 8,
                  [:cell, "a"], 
                  [:cell, "b"]],
                [:row, 9,
                  [:cell, "c"], 
                  [:cell, "d"]]]]]]
        end

        it "should have examples" do
          parse("Feature: Hi

  Scenario Outline: Hello

  Given I have a table
    |1|2|

  Examples:
|x|y|
|5|6|

").to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario_outline, "Scenario Outline:", "Hello",
              [:step, 5, "Given", "I have a table",
                [:table,
                  [:row, 6, 
                    [:cell, "1"],
                    [:cell, "2"]]]],
              [:examples, "Examples:", "",
                [:table,
                  [:row, 9,
                    [:cell, "x"],
                    [:cell, "y"]],
                  [:row, 10,
                    [:cell, "5"],
                    [:cell, "6"]]]]]]
        end

        it "should allow multiline names" do
          parse(%{Feature: Hi
Scenario Outline: It is my ambition to say 
          in ten sentences
          what others say 
          in a whole book.
Given I am a step

}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario_outline, "Scenario Outline:", "It is my ambition to say\nin ten sentences\nwhat others say\nin a whole book.",
              [:step, 6, "Given", "I am a step"]]]
        end
        
        it "should allow Examples to have multiline names" do
          parse(%{Feature: Hi
Scenario Outline: name
Given I am a step

Examples: I'm a multiline name
          and I'm ok
|x|
|5|

}).to_sexp.should ==
          [:feature, nil, "Feature: Hi",
            [:scenario_outline, "Scenario Outline:", "name",
              [:step, 3, "Given", "I am a step"],
              [:examples, "Examples:", "I'm a multiline name\nand I'm ok",
                [:table,
                  [:row, 7,
                    [:cell, "x"]],
                  [:row, 8,
                    [:cell, "5"]]]]]]
        end

        it "should allow Examples to have multiline names" do
            parse(%{Feature: Hi
Scenario: When I have when in scenario
          I should be fine
Given I am a step
}).to_sexp.should ==
            [:feature, nil, "Feature: Hi",
              [:scenario, 2, "Scenario:", "When I have when in scenario\nI should be fine",
                [:step_invocation, 4, "Given", "I am a step"]]]
          end
      end

      describe "Syntax" do
        it "should parse empty_feature" do
          parse_file("empty_feature.feature")
        end

        it "should parse empty_scenario" do
          parse_file("empty_scenario.feature")
        end

        it "should parse empty_scenario_outline" do
          parse_file("empty_scenario_outline.feature")
        end

        it "should parse fit_scenario" do
          parse_file("multiline_steps.feature")
        end

        it "should parse scenario_outline" do
          parse_file("scenario_outline.feature")
        end

        it "should parse comments" do
          parse_file("with_comments.feature")
        end
      end

      describe "Filtering" do
        it "should filter outline tables" do
          path = '/self_test/features/outline_sample.feature'
          f = parse_example_file("#{path}:12")
          actual_sexp = f.to_sexp
          
          # check path is equivalent, if not same
          File.expand_path(actual_sexp[1]).should == File.expand_path(File.dirname(__FILE__) + "/../../../examples#{path}")
          actual_sexp[1] = 'made/up/path.feature'
          actual_sexp.should ==
          [:feature,
            'made/up/path.feature',
            "Feature: Outline Sample",
            [:scenario_outline,
              "Scenario Outline:",
              "Test state",
              [:step, 6, "Given", "<state> without a table"],
              [:step, 7, "Given", "<other_state> without a table"],
              [:examples,
                "Examples:",
                "Rainbow colours",
                [:table,
                  [:row, 9, 
                    [:cell, "state"], 
                    [:cell, "other_state"]
                  ],
                  [:row, 12, 
                    [:cell, "failing"], 
                    [:cell, "passing"]
                  ]
                ]
              ]
            ]
          ]
        end
      end
    end
  end
end
