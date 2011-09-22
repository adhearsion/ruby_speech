module RubySpeech
  module GRXML
    ##
    #
    # A token (a.k.a. a terminal symbol) is the part of a grammar that defines words or other entities that may be spoken. Any legal token is a legal expansion.
    #
    #   http://www.w3.org/TR/speech-grammar/#S2.1
    #
    #  The token element may include an optional xml:lang attribute to indicate the language of the contained token.
    #
    class Token < Element

      register :token

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String].freeze

      ##
      # Create a new GRXML token element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [Token] an element for use in an GRXML document
      #
      def self.new(atts = {}, &block)
        super 'token', atts, &block
      end

      def <<(arg)
        raise InvalidChildError, "A Token can only accept Strings as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :language
      end
    end # Token
  end # GRXML
end # RubySpeech
