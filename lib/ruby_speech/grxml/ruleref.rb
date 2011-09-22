module RubySpeech
  module GRXML
    ##
    #
    # The ruleref element is an empty element which points to another rule expansion in the grammar document.
    #
    #   http://www.w3.org/TR/speech-grammar/#S2.2
    #
    # Every rule definition has a local name that must be unique within the scope of the grammar in which it is defined. A rulename must match the "Name" Production of XML 1.0 [XML §2.3] and be a legal XML ID. Section 3.1 documents the rule definition mechanism and the legal naming of rules.
    #
    # The ruleref has three attributes: uri, special and type. There can be one and only one of the uri or special attribute specified on any given ruleref element.
    #
    # The uri attribute contains named identified named rule being referenced
    #
    # optional 'type' attribute specifies the media type for the uri
    #
    class Ruleref < Element

      register :ruleref

      ##
      # Create a new GRXML ruleref element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [Ruleref] an element for use in an GRXML document
      #
      def self.new(atts = {}, &block)
        super 'ruleref', atts, &block
      end

      ##
      # XML URI: in the XML Form of this specification any URI is provided as an attribute to an element; for example the ruleref and lexicon elements.
      #
      # @return [String]
      #
      def uri
        read_attr :uri
      end

      ##
      # @param [String]
      #
      # @raises ArgumentError if t is nota positive numeric value
      #
      def uri=(u)
        raise ArgumentError, "A Ruleref can only take uri or special" if special
        write_attr :uri, u
      end

      ##
      # special...
      #
      # @return [String]
      #
      def special
        read_attr :special
      end

      ##
      # @param [String]
      #
      # TODO: raise ArgumentError if not a valid special...
      #
      def special=(sp)
        raise ArgumentError, "A Ruleref can only take uri or special" if uri
        raise ArgumentError, "The Ruleref#special method only takes :NULL, :VOID, and :GARBAGE" unless %w{NULL VOID GARBAGE}.include? sp.to_s
        write_attr :special, sp
      end

      def <<(*args)
        raise InvalidChildError, "A Ruleref cannot contain children"
      end

      def eql?(o)
        super o, :uri, :special
      end
    end # Rule
  end # GRXML
end # RubySpeech
