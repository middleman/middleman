class Jeweler
  class Generator
    module RiotMixin
      def self.extended(generator)
        generator.development_dependencies << ["riot", ">= 0"]
      end

      def default_task
        'test'
      end

      def feature_support_require
        'riot/context'
      end

      def feature_support_extend
        'Riot::Context'
      end

      def test_dir
        'test'
      end

      def test_task
        'test'
      end

      def test_pattern
        'test/**/*_test.rb'
      end

      def test_filename
        "#{require_name}_test.rb"
      end

      def test_helper_filename
        "teststrap.rb"
      end

    end
  end
end
