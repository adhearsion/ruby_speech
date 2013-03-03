require 'ruby_speech/ruby_speech'

if RUBY_PLATFORM =~ /java/
  require 'jruby'
  com.benlangfeld.ruby_speech.RubySpeechService.new.basicLoad(JRuby.runtime)
end

module RubySpeech
  module GRXML
    class Matcher

      BLANK_REGEX = //.freeze

      attr_reader :grammar, :regex

      def initialize(grammar)
        @grammar = grammar
        prepare_grammar
        @regex = /^#{regexp_content.join}$/
      end

      ##
      # Checks the grammar for a match against an input string
      #
      # @param [String] other the input string to check for a match with the grammar
      #
      # @return [NoMatch, Match] depending on the result of a match attempt. If a match can be found, it will be returned with appropriate mode/confidence/utterance and interpretation attributes
      #
      # @example A grammar that takes a 4 digit pin terminated by hash, or the *9 escape sequence
      #     ```ruby
      #       grammar = RubySpeech::GRXML.draw :mode => :dtmf, :root => 'pin' do
      #         rule :id => 'digit' do
      #           one_of do
      #             ('0'..'9').map { |d| item { d } }
      #           end
      #         end
      #
      #         rule :id => 'pin', :scope => 'public' do
      #           one_of do
      #             item do
      #               item :repeat => '4' do
      #                 ruleref :uri => '#digit'
      #               end
      #               "#"
      #             end
      #             item do
      #               "\* 9"
      #             end
      #           end
      #         end
      #       end
      #
      #       matcher = RubySpeech::GRXML::Matcher.new grammar
      #
      #       >> matcher.match '*9'
      #       => #<RubySpeech::GRXML::Match:0x00000100ae5d98
      #             @mode = :dtmf,
      #             @confidence = 1,
      #             @utterance = "*9",
      #             @interpretation = "*9"
      #           >
      #       >> matcher.match '1234#'
      #       => #<RubySpeech::GRXML::Match:0x00000100b7e020
      #             @mode = :dtmf,
      #             @confidence = 1,
      #             @utterance = "1234#",
      #             @interpretation = "1234#"
      #           >
      #       >> matcher.match '5678#'
      #       => #<RubySpeech::GRXML::Match:0x00000101218688
      #             @mode = :dtmf,
      #             @confidence = 1,
      #             @utterance = "5678#",
      #             @interpretation = "5678#"
      #           >
      #       >> matcher.match '1111#'
      #       => #<RubySpeech::GRXML::Match:0x000001012f69d8
      #             @mode = :dtmf,
      #             @confidence = 1,
      #             @utterance = "1111#",
      #             @interpretation = "1111#"
      #           >
      #       >> matcher.match '111'
      #       => #<RubySpeech::GRXML::NoMatch:0x00000101371660>
      #       ```
      #
      def match(buffer)
        buffer = buffer.dup

        return check_potential_match(buffer) if regex == BLANK_REGEX

        check_full_match(buffer) || check_potential_match(buffer) || NoMatch.new
      end

      private

      def prepare_grammar
        grammar.inline!
        grammar.tokenize!
        grammar.normalize_whitespace
      end

      def check_full_match(buffer)
        match = regex.match buffer

        return unless match

        Match.new :mode           => grammar.mode,
                  :confidence     => grammar.dtmf? ? 1 : 0,
                  :utterance      => buffer,
                  :interpretation => interpret_utterance(buffer)
      end

      def regexp_content
        grammar.root_rule.children.map &:regexp_content
      end

      def interpret_utterance(utterance)
        conversion = Hash.new { |hash, key| hash[key] = key }
        conversion['*'] = 'star'
        conversion['#'] = 'pound'

        utterance.chars.inject [] do |array, digit|
          array << "dtmf-#{conversion[digit]}"
        end.join ' '
      end
    end
  end
end
