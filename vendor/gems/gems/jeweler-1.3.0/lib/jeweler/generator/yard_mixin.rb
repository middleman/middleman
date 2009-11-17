class Jeweler
  class Generator
    module YardMixin
      def self.extended(generator)
        generator.development_dependencies << ["yard", ">= 0"]
      end
      
      def doc_task
        'yardoc'
      end
    end
  end
end

