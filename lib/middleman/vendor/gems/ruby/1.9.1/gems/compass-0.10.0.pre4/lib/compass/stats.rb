module Compass
  module Stats
    class StatsVisitor
      attr_accessor :rule_count, :prop_count, :mixin_def_count, :mixin_count
      def initialize
        self.rule_count = 0
        self.prop_count = 0
        self.mixin_def_count = 0
        self.mixin_count = 0
      end
      def visit(node)
        self.prop_count += 1 if node.is_a?(Sass::Tree::PropNode) && !node.children.any?
        if node.is_a?(Sass::Tree::RuleNode)
          self.rule_count += node.rules.map{|r| r.split(/,/)}.flatten.compact.size
        end
        self.mixin_def_count += 1 if node.is_a?(Sass::Tree::MixinDefNode)
        self.mixin_count += 1 if node.is_a?(Sass::Tree::MixinNode)
      end
      def up(node)
      end
      def down(node)
      end
      def import?(node)
        return false
        full_filename = node.send(:import)
        full_filename != Compass.deprojectize(full_filename)
      end
    end
    class CssFile
      attr_accessor :path, :css
      attr_accessor :selector_count, :prop_count
      def initialize(path)
        require 'css_parser'
        self.path = path
        self.css = CssParser::Parser.new
        self.css.add_block!(contents)
        self.selector_count = 0
        self.prop_count = 0
      end
      def contents
        @contents ||= File.read(path)
      end
      def lines
        contents.inject(0){|m,c| m + 1 }
      end
      def analyze!
        css.each_selector do |selector, declarations, specificity|
          sels = selector.split(/,/).size
          props = declarations.split(/;/).size
          self.selector_count += sels
          self.prop_count += props
        end
      end
    end
    class SassFile
      attr_accessor :path
      attr_reader :visitor
      def initialize(path)
        self.path = path
      end
      def contents
        @contents ||= File.read(path)
      end
      def tree
        @tree = Sass::Engine.new(contents, Compass.configuration.to_sass_engine_options).to_tree
      end
      def visit_tree!
        @visitor = StatsVisitor.new
        tree.visit_depth_first(@visitor)
        @visitor
      end
      def analyze!
        visit_tree!
      end
      def lines
        contents.inject(0){|m,c| m + 1 }
      end
      def rule_count
        visitor.rule_count
      end
      def prop_count
        visitor.prop_count
      end
      def mixin_def_count
        visitor.mixin_def_count
      end
      def mixin_count
        visitor.mixin_count
      end
    end
  end
end
