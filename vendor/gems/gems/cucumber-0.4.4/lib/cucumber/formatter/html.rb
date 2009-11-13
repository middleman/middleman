require 'cucumber/formatter/ordered_xml_markup'
require 'cucumber/formatter/duration'
require 'cucumber/formatter/summary'

module Cucumber
  module Formatter
    # The formatter used for <tt>--format html</tt>
    class Html
      include ERB::Util # for the #h method
      include Duration
      include Summary

      def initialize(step_mother, io, options)
        @io = io
        @options = options
        @buffer = {}
        @step_mother = step_mother
        @current_builder = create_builder(@io)
      end
      
      def before_features(features)
        start_buffering :features
      end
      
      def after_features(features)
        stop_buffering :features
        # <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        builder.declare!(
          :DOCTYPE,
          :html, 
          :PUBLIC, 
          '-//W3C//DTD XHTML 1.0 Strict//EN', 
          'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
        )
        builder.html(:xmlns => 'http://www.w3.org/1999/xhtml') do
          builder.head do
            builder.meta(:content => 'text/html;charset=utf-8')
            builder.title 'Cucumber'
            inline_css
          end
          builder.body do
            builder.div(:class => 'cucumber') do
              builder << buffer(:features)
              builder.div(scenario_summary(@step_mother) {|status_count, _| status_count}, :class => 'summary')
              builder.div(step_summary(@step_mother) {|status_count, _| status_count}, :class => 'summary')
              builder.div(format_duration(features.duration), :class => 'duration')
            end
          end
        end
      end
      
      def before_feature(feature)
        start_buffering :feature
        @exceptions = []
      end
      
      def after_feature(feature)
        stop_buffering :feature
        builder.div(:class => 'feature') do
          builder << buffer(:feature)
        end
      end

      def before_comment(comment)
        start_buffering :comment
      end

      def after_comment(comment)
        stop_buffering :comment
        builder.pre(:class => 'comment') do
          builder << buffer(:comment)
        end
      end

      def comment_line(comment_line)
        builder.text!(comment_line)
        builder.br
      end
      
      def after_tags(tags)
        @tag_spacer = nil
      end
      
      def tag_name(tag_name)
        builder.text!(@tag_spacer) if @tag_spacer
        @tag_spacer = ' '
        builder.span(tag_name, :class => 'tag')
      end

      def feature_name(name)
        lines = name.split(/\r?\n/)
        return if lines.empty?
        builder.h2 do |h2|
          builder.span(lines[0], :class => 'val')
        end
        builder.p(:class => 'narrative') do
          lines[1..-1].each do |line|
            builder.text!(line.strip)
            builder.br
          end
        end
      end

      def before_background(background)
        @in_background = true
        start_buffering :background
      end
      
      def after_background(background)
        stop_buffering :background
        @in_background = nil
        builder.div(:class => 'background') do
          builder << buffer(:background)
        end
      end

      def background_name(keyword, name, file_colon_line, source_indent)
        @listing_background = true
        builder.h3 do |h3|
          builder.span(keyword, :class => 'keyword')
          builder.text!(' ')
          builder.span(name, :class => 'val')
        end
      end

      def before_feature_element(feature_element)
        start_buffering :feature_element
      end
      
      def after_feature_element(feature_element)
        stop_buffering :feature_element
        css_class = {
          Ast::Scenario        => 'scenario',
          Ast::ScenarioOutline => 'scenario outline'
        }[feature_element.class]

        builder.div(:class => css_class) do
          builder << buffer(:feature_element)
        end
        @open_step_list = true
      end

      def scenario_name(keyword, name, file_colon_line, source_indent)
        @listing_background = false
        builder.h3 do
          builder.span(keyword, :class => 'keyword')
          builder.text!(' ')
          builder.span(name, :class => 'val')
        end
      end
      
      def before_outline_table(outline_table)
        @outline_row = 0
        start_buffering :outline_table
      end
      
      def after_outline_table(outline_table)
        stop_buffering :outline_table
        builder.table do
          builder << buffer(:outline_table)
        end
        @outline_row = nil
      end

      def before_examples(examples)
        start_buffering :examples
      end
      
      def after_examples(examples)
        stop_buffering :examples
        builder.div(:class => 'examples') do
          builder << buffer(:examples)
        end
      end

      def examples_name(keyword, name)
        builder.h4 do
          builder.span(keyword, :class => 'keyword')
          builder.text!(' ')
          builder.span(name, :class => 'val')
        end
      end

      def before_steps(steps)
        start_buffering :steps
      end
      
      def after_steps(steps)
        stop_buffering :steps
        builder.ol do
          builder << buffer(:steps)
        end
      end
      
      def before_step(step)
        @step_id = step.dom_id
      end

      def before_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        start_buffering :step_result
        @hide_this_step = false
        if exception
          if @exceptions.include?(exception)
            @hide_this_step = true
            return
          end
          @exceptions << exception
        end
        if status != :failed && @in_background ^ background
          @hide_this_step = true
          return
        end
        @status = status
      end
      
      def after_step_result(keyword, step_match, multiline_arg, status, exception, source_indent, background)
        stop_buffering :step_result
        return if @hide_this_step
        builder.li(:id => @step_id, :class => "step #{status}") do
          builder << buffer(:step_result)
        end
      end

      def step_name(keyword, step_match, status, source_indent, background)
        @step_matches ||= []
        background_in_scenario = background && !@listing_background
        @skip_step = @step_matches.index(step_match) || background_in_scenario
        @step_matches << step_match
      
        unless @skip_step
          build_step(keyword, step_match, status)
        end
      end

      def exception(exception, status)
        return if @hide_this_step
        builder.pre(format_exception(exception), :class => status)
      end
      
      def before_multiline_arg(multiline_arg)
        start_buffering :multiline_arg
      end

      def after_multiline_arg(multiline_arg)
        stop_buffering :multiline_arg
        return if @hide_this_step || @skip_step
        if Ast::Table === multiline_arg
          builder.table do
            builder << buffer(:multiline_arg)
          end
        else
          builder << buffer(:multiline_arg)
        end
      end

      def py_string(string)
        return if @hide_this_step
        builder.pre(:class => 'val') do |pre|
          builder << string.gsub("\n", '&#x000A;')
        end
      end

      def before_table_row(table_row)
        @row_id = table_row.dom_id
        @col_index = 0
        start_buffering :table_row
      end
      
      def after_table_row(table_row)
        stop_buffering :table_row
        return if @hide_this_step
        builder.tr(:id => @row_id) do
          builder << buffer(:table_row)
        end
        if table_row.exception
          builder.tr do
            builder.td(:colspan => @col_index.to_s, :class => 'failed') do
              builder.pre do |pre|
                pre << format_exception(table_row.exception)
              end
            end
          end
        end
        @outline_row += 1 if @outline_row
      end

      def table_cell_value(value, status)
        return if @hide_this_step
        
        cell_type = @outline_row == 0 ? :th : :td
        attributes = {:id => "#{@row_id}_#{@col_index}", :class => 'val'}
        attributes[:class] += " #{status}" if status
        build_cell(cell_type, value, attributes)
        @col_index += 1
      end

      def announce(announcement)
        builder.pre(announcement, :class => 'announcement')
      end

      def embed(file, mime_type)
        case(mime_type)
        when /^image\/(png|gif|jpg)/
          embed_image(file)
        end
      end

      private
      
      def embed_image(file)
        id = file.hash
        builder.pre(:class => 'embed') do |pre|
          pre << %{<a href="#" onclick="img=document.getElementById('#{id}'); img.style.display = (img.style.display == 'none' ? 'block' : 'none');">Screenshot</a>
          <img id="#{id}" style="display: none" src="#{file}" />}
        end
      end

      def build_step(keyword, step_match, status)
        step_name = step_match.format_args(lambda{|param| %{<span class="param">#{param}</span>}})
        builder.div do |div|
          builder.span(keyword, :class => 'keyword')
          builder.text!(' ')
          builder.span(:class => 'step val') do |name|
            name << h(step_name).gsub(/&lt;span class=&quot;(.*?)&quot;&gt;/, '<span class="\1">').gsub(/&lt;\/span&gt;/, '</span>')
          end
        end
      end

      def build_cell(cell_type, value, attributes)
        builder.__send__(cell_type, value, attributes)
      end
      
      def inline_css
        builder.style(:type => 'text/css') do
          builder.text!(File.read(File.dirname(__FILE__) + '/cucumber.css'))
        end
      end
      
      def format_exception(exception)
        h((["#{exception.message} (#{exception.class})"] + exception.backtrace).join("\n"))
      end
      
      def builder
        @current_builder
      end
      
      def buffer(label)
        result = @buffer[label]
        @buffer[label] = ''
        result
      end
      
      def start_buffering(label)
        @buffer[label] ||= ''
        @parent_builder ||= {}
        @parent_builder[label] = @current_builder
        @current_builder = create_builder(@buffer[label])
      end
      
      def stop_buffering(label)
        @current_builder = @parent_builder[label]
      end
      
      def create_builder(io)
        OrderedXmlMarkup.new(:target => io, :indent => 0)
      end      
    end
  end
end
