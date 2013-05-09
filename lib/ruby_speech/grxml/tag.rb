module RubySpeech
  module GRXML
    ##
    #
    # The tag element is one of the valid expansion elements for the SGR rule element
    #
    #   http://www.w3.org/TR/speech-grammar/#S2.6
    #
    #
    # TODO: Make sure this is complete...
    #
    #
    class Tag < Element

      register :tag

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String].freeze

      def <<(arg)
        raise InvalidChildError, "A Tag can only accept Strings as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def regexp_content # :nodoc:
        "?<t#{content}>"
      end
    end # Tag
  end # GRXML
end # RubySpeech
