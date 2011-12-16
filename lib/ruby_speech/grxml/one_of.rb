module RubySpeech
  module GRXML
    ##
    #
    # The one-of element is one of the valid expansion elements for the SGR rule element
    #
    # http://www.w3.org/TR/speech-grammar/#S2.4 --> XML Form
    #
    # The one-of element has no attributes
    #
    # The one-of element identifies a set of alternative elements. Each alternative expansion is contained in a item element. There must be at least one item element contained within a one-of element.
    #
    # FIXME: Ensure an 'item' element is in the oneof block... this may be at the final draw or when OneOf is called...
    #
    class OneOf < Element

      register :'one-of'

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, Item].freeze

      ##
      # Create a new GRXML one-of element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [OneOf] an element for use in an GRXML document
      #
      def self.new(atts = {}, &block)
        super 'one-of', atts, &block
      end

      def <<(arg)
        raise InvalidChildError, "A OneOf can only accept Item as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end
    end # OneOf
  end # GRXML
end # RubySpeech
