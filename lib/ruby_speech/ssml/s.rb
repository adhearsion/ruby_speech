module RubySpeech
  module SSML
    ##
    # As s element represents a sentence.
    # The use of s elements is optional. Where text occurs without an enclosing s element the synthesis processor should attempt to determine the structure using language-specific knowledge of the format of plain text.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.1.7
    #
    class S < Element

      register :s

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String, Audio, Break, Emphasis, Mark, Phoneme, Prosody, SayAs, Sub, Voice].freeze

      def <<(arg)
        raise InvalidChildError, "An S can only accept String, Audio, Break, Emphasis, Mark, Phoneme, Prosody, SayAs, Sub, Voice as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :language
      end
    end # S
  end # SSML
end # RubySpeech
