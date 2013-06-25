require 'ruby_speech/ssml/element'
require 'ruby_speech/xml/language'

module RubySpeech
  module SSML
    ##
    # The emphasis element requests that the contained text be spoken with emphasis (also referred to as prominence or stress). The synthesis processor determines how to render emphasis since the nature of emphasis differs between languages, dialects or even voices.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.2.2
    #
    class Desc < Element
      include XML::Language

      register :desc

      VALID_CHILD_TYPES = [Nokogiri::XML::Text, String].freeze

      def <<(arg)
        raise InvalidChildError, "A Desc can only accept Strings as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :language
      end
    end # Desc
  end # SSML
end # RubySpeech
