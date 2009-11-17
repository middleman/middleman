require 'cucumber/formatter/pretty'
require 'cucumber/parser/natural_language'
require 'cucumber/formatter/unicode'

module Cucumber
  module Cli
    class LanguageHelpFormatter < Formatter::Pretty
      INCOMPLETE = %{
The Cucumber grammar has evolved since this translation was written.
Please help us complete the translation by translating the missing words in

#{Cucumber::LANGUAGE_FILE}

Then contribute back to the Cucumber project. Details here:
http://wiki.github.com/aslakhellesoy/cucumber/spoken-languages
}
      
      class << self
        def list_languages(io)
          raw = Cucumber::LANGUAGES.keys.sort.map do |lang|
            [
              lang, 
              Cucumber::LANGUAGES[lang]['name'], 
              Cucumber::LANGUAGES[lang]['native']
            ]
          end

          print_table io, raw, :check_lang => true
        end

        def list_keywords(io, lang)
          language = Parser::NaturalLanguage.get(nil, lang)
          raw = Parser::NaturalLanguage::KEYWORD_KEYS.map do |key|
            [key, language.keywords(key)]
          end
          
          print_table io, raw, :incomplete => language.incomplete?
        end
      
        private
          def print_table(io, raw, options)
            table = Ast::Table.new(raw)
            formatter = new(nil, io, options)
            Ast::TreeWalker.new(nil, [formatter]).visit_multiline_arg(table)
          end
      end
      
      def before_visit_multiline_arg(table)
        if @options[:incomplete]
          @io.puts(format_string(INCOMPLETE, :failed))
        end
      end

      def before_visit_table_row(table_row)
        @col = 1
      end

      def before_visit_table_cell_value(value, status)
        if @col == 1
          if(@options[:check_lang])
            @incomplete = Parser::NaturalLanguage.get(nil, value).incomplete?
          end
          status = :comment 
        elsif @incomplete
          status = :undefined
        end
        
        @col += 1
      end
    end
  end
end