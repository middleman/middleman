module Compass
  module Commands
    class ListFrameworks < ProjectBase
      attr_accessor :options
      def initialize(working_path, options)
        super
      end
  
      def execute
        Compass::Frameworks::ALL.each do |framework|
          puts framework.name
        end
      end
    end
  end
end