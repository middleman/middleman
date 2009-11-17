module Cucumber
  module Parser
    class NaturalLanguage
      KEYWORD_KEYS = %w{name native encoding space_after_keyword feature background scenario scenario_outline examples given when then and but}

      class << self
        def get(step_mother, lang)
          languages[lang] ||= new(step_mother, lang)
        end

        def languages
          @languages ||= {}
        end
      end

      def initialize(step_mother, lang)
        @keywords = Cucumber::LANGUAGES[lang]
        raise "Language not supported: #{lang.inspect}" if @keywords.nil?
        @keywords['grammar_name'] = @keywords['name'].gsub(/\s/, '')
        register_adverbs(step_mother) if step_mother
        @parser = nil
      end

      def register_adverbs(step_mother)
        adverbs = %w{given when then and but}.map{|keyword| @keywords[keyword].split('|').map{|w| w.gsub(/\s/, '')}}.flatten
        step_mother.register_adverbs(adverbs) if step_mother
      end

      def parser
        return @parser if @parser
        i18n_tt = File.expand_path(File.dirname(__FILE__) + '/i18n.tt')
        template = File.open(i18n_tt, Cucumber.file_mode('r')).read
        erb = ERB.new(template)
        grammar = erb.result(binding)
        Treetop.load_from_string(grammar)
        @parser = Parser::I18n.const_get("#{@keywords['grammar_name']}Parser").new
        def @parser.inspect
          "#<#{self.class.name}>"
        end
        @parser
      end

      def parse(source, path, filter)
        feature = parser.parse_or_fail(source, path, filter)
        feature.language = self if feature
        feature
      end

      def keywords(key, raw=false)
        return @keywords[key] if raw
        return nil unless @keywords[key]
        values = @keywords[key].to_s.split('|')
        values.map{|value| "'#{value}'"}.join(" / ")
      end

      def incomplete?
        KEYWORD_KEYS.detect{|key| @keywords[key].nil?}
      end

      def scenario_keyword
        @keywords['scenario'].split('|')[0] + ':'
      end

      def but_keywords
        @keywords['but'].split('|')
      end

      def and_keywords
        @keywords['and'].split('|')
      end

      def step_keywords
        %w{given when then and but}.map{|key| @keywords[key].split('|')}.flatten.uniq
      end

      def space_after_keyword
        @keywords['space_after_keyword']
      end
    end
  end
end
