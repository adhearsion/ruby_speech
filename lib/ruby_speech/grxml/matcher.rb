require 'ruby_speech/grxml/match'
require 'ruby_speech/grxml/no_match'
require 'ruby_speech/grxml/potential_match'
require 'ruby_speech/grxml/max_match'
require 'ruby_speech/ruby_speech'

if RUBY_PLATFORM =~ /java/
  require 'jruby'
  com.benlangfeld.ruby_speech.RubySpeechService.new.basicLoad(JRuby.runtime)
end

module RubySpeech
  module GRXML
    class Matcher
      UTTERANCE_CONVERTER = Hash.new { |hash, key| hash[key] = key }
      UTTERANCE_CONVERTER['*'] = 'star'
      UTTERANCE_CONVERTER['#'] = 'pound'

      attr_reader :grammar

      def initialize(grammar)
        @grammar = grammar
        prepare_grammar
        compile_regex regexp_content.gsub(/\?<[\w\d\s]*>/, '')
      end

      ##
      # Checks the grammar for a match against an input string
      #
      # @param [String] other the input string to check for a match with the grammar
      #
      # @return [NoMatch, PotentialMatch, Match, MaxMatch] depending on the result of a match attempt. A potential match indicates that the buffer is valid, but incomplete. A MaxMatch is differentiated from a Match in that it cannot accept further input. If a match can be found, it will be returned with appropriate mode/confidence/utterance and interpretation attributes
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
        find_match buffer.dup
      end

      private

      def regexp_content
        '^' + grammar.root_rule.children.map(&:regexp_content).join + '$'
      end

      def prepare_grammar
        grammar.inline!
        grammar.tokenize!
        grammar.normalize_whitespace
      end

      def match_for_buffer(buffer, maximal = false)
        match_class = maximal ? MaxMatch : Match
        match_class.new mode:     grammar.mode,
                  confidence:     grammar.dtmf? ? 1 : 0,
                  utterance:      buffer,
                  interpretation: interpret_utterance(buffer)
      end

      def interpret_utterance(utterance)
        find_tag(utterance) || utterance.chars.inject([]) do |array, digit|
          array << "dtmf-#{UTTERANCE_CONVERTER[digit]}"
        end.join(' ')
      end

      def find_tag(utterance)
        match = /#{regexp_content}/.match(utterance)
        return if match.captures.all?(&:nil?)
        last_capture_index = match.captures.size - 1 - match.captures.reverse.find_index { |item| !item.nil? }
        group = match.names[last_capture_index]
        group && group[1..-1]
      end
    end
  end
end
