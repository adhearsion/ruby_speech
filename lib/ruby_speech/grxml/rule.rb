module RubySpeech
  module GRXML
    ##
    # 
    # A rule definition associates a legal rule expansion with a rulename. The rule definition is also responsible for defining the scope of the rule definition: whether it is local to the grammar in which it is defined or whether it may be referenced within other grammars.
    #
    # http://www.w3.org/TR/speech-grammar/#S3
    #
    # The rule element has two attributes: id and scope. The id attribute is always required; the scope is optional.
    #
    # The id must be unique with-in the grammar document
    #
    # The scope is either "private" or "public".  If it is not explicitly declared in a rule definition then the scope defaults to "private".
    #
    #
    class Rule < Element

      register :'rule'

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, OneOf, Item, Ruleref, Tag].freeze

      ##
      # Create a new GRXML rule element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [Rule] an element for use in an GRXML document
      #
      def self.new(atts = {}, &block)
        super 'rule', atts, &block
      end

      ##
      #
      # The id attribute is the unique name to identify the rule
      #
      #
      # @return [String]
      #
      def id
        read_attr :'id'
      end

      ##
      # @param [String] ia
      #
      def id=(ia)
        write_attr :'id', ia
      end

      ##
      #
      # The scope attribute is optional...
      #
      # @return [String]
      #
      def scope
        read_attr :'scope'
      end

      ##
      #
      # The scope attribute should only be "private" or "public"
      #
      # @param [String] ia
      #
      def scope=(sc)
        sc = sc.to_s 
        raise ArgumentError, "A Rule's scope can only be 'public' or 'private'" unless (sc == "public" or sc == "private")
        write_attr :'scope', sc.to_s
      end

      def <<(arg)
        raise InvalidChildError, "A Rule can only accept OneOf, Item, Ruleref, or Tag as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :id, :scope
      end
    end # Rule
  end # GRXML
end # RubySpeech
