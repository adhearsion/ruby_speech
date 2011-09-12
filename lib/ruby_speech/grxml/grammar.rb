module RubySpeech
  module GRXML
    ##
    # The Speech Recognition Grammar Language is an XML application. The root element is grammar.
    #
    # http://www.w3.org/TR/speech-grammar/#S4.3
    #
    # TODO: Look into tag-format, lexicon (probably a sub element)
    #
    class Grammar < Element
      include XML::Language

      register :grammar

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, Rule].freeze

      ##
      # Create a new GRXML grammar root element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [Grammar] an element for use in an GRXML document
      #
      def self.new(atts = {}, &block)
        new_node = super('grammar', atts)
        new_node[:version] = '1.0'
        new_node.namespace = GRXML_NAMESPACE
        new_node.language ||= "en-US"
        new_node.instance_eval &block if block_given?
        new_node
      end

      ##
      # @return [String] the base URI to which relative URLs are resolved
      #
      def base_uri
        read_attr :base
      end

      ##
      # @param [String] uri the base URI to which relative URLs are resolved
      #
      def base_uri=(uri)
        write_attr 'xml:base', uri
      end

      ##
      #
      # The mode of a grammar indicates the type of input that the user agent should be detecting. The default mode is "voice" for speech recognition grammars. An alternative input mode is "dtmf" input".
      #
      # @return [String]
      #
      def mode
        read_attr :mode
      end

      ##
      # @param [String] ia
      #
      def mode=(ia)
        write_attr :mode, ia
      end

      ##
      #
      # The root ("rule") attribute indicates declares a single rule to be the root rle of the grammar.  This attribute is OPTIONAL. The rule declared must be defined within the scope of the grammar.  It specified rule can be scoped "public" or "private."
      #
      # @return [String]
      #
      def root
        read_attr :root
      end

      ##
      # @param [String] ia
      #
      def root=(ia)
        write_attr :root, ia
      end

      def <<(arg)
        raise InvalidChildError, "A Grammar can only accept Rule as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def to_doc
        Nokogiri::XML::Document.new.tap do |doc|
          doc << self
        end
      end

      def +(other)
        self.class.new(:base_uri => base_uri).tap do |new_grammar|
          (self.children + other.children).each do |child|
            new_grammar << child
          end
        end
      end

      def eql?(o)
        super o, :language, :base_uri, :mode, :root
      end
    end # Grammar
  end # GRXML
end # RubySpeech
