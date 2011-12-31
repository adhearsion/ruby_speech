module RubySpeech
  module GRXML
    ##
    #
    # A rule definition associates a legal rule expansion with a rulename. The rule definition is also responsible for defining the scope of the rule definition: whether it is local to the grammar in which it is defined or whether it may be referenced within other grammars.
    #
    #   http://www.w3.org/TR/speech-grammar/#S3
    #   http://www.w3.org/TR/speech-grammar/#S3.1
    #
    # The rule element has two attributes: id and scope. The id attribute is always required; the scope is optional.
    #
    # The id must be unique with-in the grammar document
    #
    # The scope is either "private" or "public".  If it is not explicitly declared in a rule definition then the scope defaults to "private".
    #
    #
    class Rule < Element
      include XML::Language

      register :rule

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String, OneOf, Item, Ruleref, Tag, Token].freeze

      ##
      #
      # The id attribute is the unique name to identify the rule
      #
      #
      # @return [String]
      #
      def id
        read_attr :id, :to_sym
      end

      ##
      # @param [String] ia
      #
      def id=(ia)
        write_attr :id, ia
      end

      ##
      #
      # The scope attribute is optional...
      #
      # @return [String]
      #
      def scope
        read_attr :scope, :to_sym
      end

      ##
      #
      # The scope attribute should only be "private" or "public"
      #
      # @param [String] ia
      #
      def scope=(sc)
        raise ArgumentError, "A Rule's scope can only be 'public' or 'private'" unless %w{public private}.include?(sc.to_s)
        write_attr :scope, sc
      end

      def <<(arg)
        raise InvalidChildError, "A Rule can only accept OneOf, Item, Ruleref, Tag, or Token as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :id, :scope, :language
      end
    end # Rule
  end # GRXML
end # RubySpeech
