class Jeweler
  class Generator
    module RspecMixin
      def self.extended(generator)
        generator.development_dependencies << ["rspec", ">= 1.2.9"]
      end

      def default_task
        'spec'
      end

      def feature_support_require
        'spec/expectations'
      end

      def feature_support_extend
        nil # Cucumber is smart enough extend Spec::Expectations on its own
      end

      def test_dir
        'spec'
      end

      def test_task
        'spec'
      end

      def test_pattern
        'spec/**/*_spec.rb'
      end

      def test_filename
        "#{require_name}_spec.rb"
      end

      def test_helper_filename
        "spec_helper.rb"
      end

    end
  end
end
