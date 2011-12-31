module RubySpeech
  module SSML
    ##
    # The Speech Synthesis Markup Language is an XML application. The root element is speak.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.1.1
    #
    class Speak < Element
      include XML::Language

      register :speak

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, S, SayAs, Sub, Voice].freeze

      def <<(arg)
        raise InvalidChildError, "A Speak can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :language, :base_uri
      end
    end # Speak
  end # SSML
end # RubySpeech
