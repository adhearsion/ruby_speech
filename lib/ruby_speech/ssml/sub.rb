module RubySpeech
  module SSML
    ##
    # The sub element is employed to indicate that the text in the alias attribute value replaces the contained text for pronunciation. This allows a document to contain both a spoken and written form. The required alias attribute specifies the string to be spoken instead of the enclosed string. The processor should apply text normalization to the alias value.
    #
    # The sub element can only contain text (no elements).
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.1.10
    #
    class Sub < Element

      register :sub

      VALID_CHILD_TYPES = [Nokogiri::XML::Text, String].freeze

      ##
      # Create a new SSML sub element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [Sub] an element for use in an SSML document
      #
      def self.new(atts = {}, &block)
        super 'sub', atts, &block
      end

      ##
      # Indicates the string to be spoken instead of the enclosed string
      #
      # @return [String]
      #
      def alias
        read_attr :alias
      end

      ##
      # @param [String] other the string to be spoken instead of the enclosed string
      #
      def alias=(other)
        write_attr :alias, other
      end

      def <<(arg)
        raise InvalidChildError, "A Sub can only accept Strings as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :alias
      end
    end # Sub
  end # SSML
end # RubySpeech
