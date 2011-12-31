module RubySpeech
  module SSML
    ##
    # The emphasis element requests that the contained text be spoken with emphasis (also referred to as prominence or stress). The synthesis processor determines how to render emphasis since the nature of emphasis differs between languages, dialects or even voices.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.2.2
    #
    class Desc < Element

      register :desc

      VALID_CHILD_TYPES = [Nokogiri::XML::Text, String].freeze

      ##
      # Create a new SSML emphasis element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [Emphasis] an element for use in an SSML document
      #
      def self.new(atts = {}, &block)
        super 'desc', atts, &block
      end

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
