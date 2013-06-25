require 'ruby_speech/ssml/element'
require 'ruby_speech/xml/language'

module RubySpeech
  module SSML
    ##
    # A p element represents a paragraph.
    # The use of p elements is optional. Where text occurs without an enclosing p element the synthesis processor should attempt to determine the structure using language-specific knowledge of the format of plain text.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.1.7
    #
    class P < Element

      %w{
        audio
        break
        desc
        element
        emphasis
        mark
        phoneme
        prosody
        s
        say_as
        speak
        sub
        voice
      }.each { |f| require "ruby_speech/ssml/#{f}" }

      include XML::Language

      register :p

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String, Audio, Break, Emphasis, Mark, Phoneme, Prosody, S, SayAs, Sub, Voice].freeze

      def <<(arg)
        raise InvalidChildError, "A P can only accept String, Audio, Break, Emphasis, Mark, Phoneme, Prosody, SayAs, Sub, S, Voice as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :language
      end
    end # P
  end # SSML
end # RubySpeech
