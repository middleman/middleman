module Templater
  module Spec
    module Helpers

      class InvokeMatcher
        def initialize(expected)
          @expected = expected
        end

        def matches?(actual)
          @actual = actual
          # Satisfy expectation here. Return false or raise an error if it's not met.
          found = nil
          @actual.invocations.each { |i| found = i if i.class == @expected }

          if @with
            return found && (@with == found.arguments)
          else
            return found
          end
        end

        def with(*arguments)
          @with = arguments
          return self
        end

        def failure_message
          "expected #{@actual.inspect} to invoke #{@expected.inspect} with #{@with}, but it didn't"
        end

        def negative_failure_message
          "expected #{@actual.inspect} not to invoke #{@expected.inspect} with #{@with}, but it did"
        end
      end

      def invoke(expected)
        InvokeMatcher.new(expected)
      end

      class CreateMatcher
        def initialize(expected)
          @expected = expected
        end

        def matches?(actual)
          @actual = actual
          # Satisfy expectation here. Return false or raise an error if it's not met.
          @actual.all_actions.map{|t| t.destination }.include?(@expected)
        end

        def failure_message
          "expected #{@actual.inspect} to create #{@expected.inspect}, but it didn't"
        end

        def negative_failure_message
          "expected #{@actual.inspect} not to create #{@expected.inspect}, but it did"
        end
      end

      def create(expected)
        CreateMatcher.new(expected)
      end

    end # Helpers
  end # Spec
end # Templater