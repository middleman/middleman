require 'enumerator'
require 'cucumber/ast/tags'

module Cucumber
  module Ast
    module FeatureElement #:nodoc:
      attr_accessor :feature

      def attach_steps(steps)
        steps.each {|step| step.feature_element = self}
      end

      def file_colon_line(line = @line)
        @feature.file_colon_line(line) if @feature
      end

      def text_length
        name_line_lengths.max
      end

      def first_line_length
        name_line_lengths[0]
      end

      def name_line_lengths
        if @name.strip.empty?
          [@keyword.jlength]
        else
          @name.split("\n").enum_for(:each_with_index).map do |line, line_number|
            line_number == 0 ? @keyword.jlength + line.jlength : line.jlength + Ast::Step::INDENT - 1 # We -1 as names which are not keyword lines are missing a space between keyword and name
          end
        end
      end

      def matches_scenario_names?(scenario_name_regexps)
        scenario_name_regexps.detect{|name| name =~ @name}
      end

      def backtrace_line(name = "#{@keyword} #{@name}", line = @line)
        @feature.backtrace_line(name, line) if @feature
      end

      def source_indent(text_length)
        max_line_length - text_length
      end

      def max_line_length
        @steps.max_line_length(self)
      end

      def accept_hook?(hook)
        Tags.matches?(source_tag_names, hook.tag_name_lists)
      end

      def source_tag_names
        (@tags.tag_names + (@feature ? @feature.source_tag_names : [])).uniq
      end

      def tag_count(tag)
        @feature.tag_count(tag) == 0 ? @tags.count(tag) : @feature.tag_count(tag)
      end

      def language
        @feature.language if @feature
      end
    end
  end
end
