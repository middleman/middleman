class Jeweler
  class Generator
    module BaconMixin

      def self.extended(generator)
        generator.development_dependencies << ["bacon", ">= 0"]
      end

      def default_task
        'spec'
      end

      def feature_support_require
        'test/unit/assertions'
      end

      def feature_support_extend
        'Test::Unit::Assertions' # NOTE can't use bacon inside of cucumber actually
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
