module RubySpeech
  module GRXML
    ##
    # The Speech Recognition Grammar Language is an XML application. The root element is grammar.
    #
    # http://www.w3.org/TR/speech-grammar/#S4.3
    #
    # Attributes: uri, language, root, tag-format
    #
    # tag-format declaration is an optional declaration of a tag-format identifier that indicates the content type of all tags contained within a grammar.
    #
    # NOTE: A grammar without rules is allowed but cannot be used for processing input -- http://www.w3.org/Voice/2003/srgs-ir/
    #
    # TODO: Look into lexicon (probably a sub element)
    #
    class Grammar < Element
      include XML::Language

      register :grammar

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, Rule, Tag].freeze

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

      ##
      #
      # @return [String]
      #
      def tag_format
        read_attr :'tag-format'
      end

      ##
      # @param [String] ia
      #
      def tag_format=(s)
        write_attr :'tag-format', s
      end

      def root_rule
        children(:rule, :id => root).first
      end

      def inline
        clone.inline!
      end

      def inline!
        find("//ns:ruleref", :ns => namespace_href).each do |ref|
          rule = children(:rule, :id => ref[:uri].sub(/^#/, '')).first
          ref.swap rule.nokogiri_children
        end

        non_root_rules = xpath "./ns:rule[@id!='#{root}']", :ns => namespace_href
        non_root_rules.remove

        self
      end

      def tokenize!
        traverse do |element|
          next unless element.is_a? Nokogiri::XML::Text

          next if self.class.import(element.parent).is_a? Token

          tokens = split_tokens(element).map do |string|
            Token.new.tap { |token| token << string }
          end

          element.swap Nokogiri::XML::NodeSet.new(Nokogiri::XML::Document.new, tokens)
        end
      end

      def split_tokens(element)
        element.to_s.split(/(\".*\")/).reject(&:empty?).map do |string|
          match = string.match /^\"(.*)\"$/
          match ? match[1] : string.split(' ')
        end.flatten
      end

      def normalize_whitespace
        traverse do |element|
          next if element === self

          imported_element = self.class.import element
          next unless imported_element.respond_to? :normalize_whitespace

          imported_element.normalize_whitespace
          element.swap imported_element
        end
      end

      def <<(arg)
        raise InvalidChildError, "A Grammar can only accept Rule and Tag as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :language, :base_uri, :mode, :root
      end
    end # Grammar
  end # GRXML
end # RubySpeech
