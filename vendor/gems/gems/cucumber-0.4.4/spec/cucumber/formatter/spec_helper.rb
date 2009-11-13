module Cucumber
  module Formatter

    module SpecHelperDsl
      attr_reader :feature_content, :step_defs
    
      def define_feature(string)
        @feature_content = string
      end
    
      def define_steps(&block)
        @step_defs = block
      end
    end

    module SpecHelper
      def run_defined_feature
        define_steps
        features = load_features(self.class.feature_content || raise("No feature content defined!"))
        run(features)
      end
      
      def step_mother
        @step_mother ||= StepMother.new
      end
      
      def load_features(content)
        feature_file = FeatureFile.new('spec.feature', content)
        features = Ast::Features.new
        features.add_feature feature_file.parse(@step_mother, {})
        features
      end
    
      def run(features)
        # options = { :verbose => true }
        options = {}
        tree_walker = Cucumber::Ast::TreeWalker.new(@step_mother, [@formatter], options, STDOUT)
        tree_walker.visit_features(features)
      end
    
      def define_steps
        return unless step_defs = self.class.step_defs
        rb = @step_mother.load_programming_language('rb')
        dsl = Object.new 
        dsl.extend RbSupport::RbDsl
        dsl.instance_exec &step_defs
      end 
    end
  end
end