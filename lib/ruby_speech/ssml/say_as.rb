module RubySpeech
  module SSML
    ##
    # The say-as element allows the author to indicate information on the type of text construct contained within the element and to help specify the level of detail for rendering the contained text.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.1.8
    #
    # Defining a comprehensive set of text format types is difficult because of the variety of languages that have to be considered and because of the innate flexibility of written languages. SSML only specifies the say-as element, its attributes, and their purpose. It does not enumerate the possible values for the attributes. The Working Group expects to produce a separate document that will define standard values and associated normative behavior for these values. Examples given here are only for illustrating the purpose of the element and the attributes.
    #
    # The say-as element has three attributes: interpret-as, format, and detail. The interpret-as attribute is always required; the other two attributes are optional. The legal values for the format attribute depend on the value of the interpret-as attribute.
    #
    # The say-as element can only contain text to be rendered.
    #
    # When specified, the interpret-as and format values are to be interpreted by the synthesis processor as hints provided by the markup document author to aid text normalization and pronunciation.
    #
    # In all cases, the text enclosed by any say-as element is intended to be a standard, orthographic form of the language currently in context. A synthesis processor should be able to support the common, orthographic forms of the specified language for every content type that it supports.
    #
    # When the content of the say-as element contains additional text next to the content that is in the indicated format and interpret-as type, then this additional text must be rendered. The processor may make the rendering of the additional text dependent on the interpret-as type of the element in which it appears.
    # When the content of the say-as element contains no content in the indicated interpret-as type or format, the processor must render the content either as if the format attribute were not present, or as if the interpret-as attribute were not present, or as if neither the format nor interpret-as attributes were present. The processor should also notify the environment of the mismatch.
    #
    # Indicating the content type or format does not necessarily affect the way the information is pronounced. A synthesis processor should pronounce the contained text in a manner in which such content is normally produced for the language.
    #
    class SayAs < Element

      register :'say-as'

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String].freeze

      ##
      #
      # The interpret-as attribute indicates the content type of the contained text construct. Specifying the content type helps the synthesis processor to distinguish and interpret text constructs that may be rendered in different ways depending on what type of information is intended.
      #
      # When the value for the interpret-as attribute is unknown or unsupported by a processor, it must render the contained text as if no interpret-as value were specified.
      #
      # @return [String]
      #
      def interpret_as
        read_attr :'interpret-as'
      end

      ##
      # @param [String] ia
      #
      def interpret_as=(ia)
        write_attr :'interpret-as', ia
      end

      ##
      #
      # Can give further hints on the precise formatting of the contained text for content types that may have ambiguous formats.
      #
      # When the value for the format attribute is unknown or unsupported by a processor, it must render the contained text as if no format value were specified, and should render it using the interpret-as value that is specified.
      #
      # @return [String]
      #
      def format
        read_attr :format
      end

      ##
      # @param [String] format
      #
      def format=(format)
        write_attr :format, format
      end

      ##
      #
      # The detail attribute is an optional attribute that indicates the level of detail to be read aloud or rendered. Every value of the detail attribute must render all of the informational content in the contained text; however, specific values for the detail attribute can be used to render content that is not usually informational in running text but may be important to render for specific purposes. For example, a synthesis processor will usually render punctuations through appropriate changes in prosody. Setting a higher level of detail may be used to speak punctuations explicitly, e.g. for reading out coded part numbers or pieces of software code.
      #
      # The detail attribute can be used for all interpret-as types.
      #
      # If the detail attribute is not specified, the level of detail that is produced by the synthesis processor depends on the text content and the language.
      #
      # When the value for the detail attribute is unknown or unsupported by a processor, it must render the contained text as if no value were specified for the detail attribute.
      #
      # @return [String]
      #
      def detail
        read_attr :detail
      end

      ##
      # @param [String] detail
      #
      def detail=(detail)
        write_attr :detail, detail
      end

      def <<(arg)
        raise InvalidChildError, "A SayAs can only accept Strings as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :interpret_as, :format, :detail
      end
    end # SayAs
  end # SSML
end # RubySpeech
