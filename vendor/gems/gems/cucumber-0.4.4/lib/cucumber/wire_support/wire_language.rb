require 'socket'
require 'json'
require 'cucumber/wire_support/connection'
require 'cucumber/wire_support/wire_packet'
require 'cucumber/wire_support/wire_exception'
require 'cucumber/wire_support/wire_step_definition'

module Cucumber
  module WireSupport
    
    # The wire-protocol (lanugage independent) implementation of the programming language API.
    class WireLanguage
      include LanguageSupport::LanguageMethods
      
      def load_code_file(wire_file)
        config = YAML.load_file(wire_file)
        @connections << Connection.new(config)
      end
      
      def step_matches(step_name, formatted_step_name)
        @connections.map{ |remote| remote.step_matches(step_name, formatted_step_name)}.flatten
      end
      
      def initialize(step_mother)
        @connections = []
      end
      
      def alias_adverbs(adverbs)
      end

      def snippet_text(step_keyword, step_name, multiline_arg_class)
        "Snippets are not implemented for the wire yet"
      end
      
      protected
      
      def begin_scenario(scenario)
        @connections.each { |remote| remote.begin_scenario(scenario) }
      end
      
      def end_scenario
        @connections.each { |remote| remote.end_scenario }
      end
      
      private
      
      def step_definitions
        @step_definitions ||= {}
      end
    end
  end
end
