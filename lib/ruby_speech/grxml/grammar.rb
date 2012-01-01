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

      self.defaults = { :version => '1.0', :language => "en-US" }

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, Rule, Tag].freeze

      ##
      #
      # The mode of a grammar indicates the type of input that the user agent should be detecting. The default mode is "voice" for speech recognition grammars. An alternative input mode is "dtmf" input".
      #
      # @return [String]
      #
      def mode
        read_attr :mode, :to_sym
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

      ##
      # @return [Rule] The root rule node for the document
      #
      def root_rule
        children(:rule, :id => root).first
      end

      ##
      # Checks for a root rule matching the value of the root tag
      #
      # @raises [InvalidChildError] if there is not a rule present in the document with the correct ID
      #
      # @return [Grammar] self
      #
      def assert_has_matching_root_rule
        raise InvalidChildError, "A GRXML document must have a rule matching the root rule name" unless has_matching_root_rule?
        self
      end

      ##
      # @return [Grammar] an inlined copy of self
      #
      def inline
        clone.inline!
      end

      ##
      # Replaces rulerefs in the document with a copy of the original rule.
      # Removes all top level rules except the root rule
      #
      # @return self
      #
      def inline!
        find("//ns:ruleref", :ns => namespace_href).each do |ref|
          rule = children(:rule, :id => ref[:uri].sub(/^#/, '')).first
          ref.swap rule.nokogiri_children
        end

        non_root_rules = xpath "./ns:rule[@id!='#{root}']", :ns => namespace_href
        non_root_rules.remove

        self
      end

      ##
      # Replaces textual content of the document with token elements containing such content.
      # This homogenises all tokens in the document to a consistent format for processing.
      #
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

      ##
      # Normalizes whitespace within tokens in the document according to the rules in the SRGS spec (http://www.w3.org/TR/speech-grammar/#S2.1)
      # Leading and trailing whitespace is removed, and multiple spaces within the string are collapsed down to single spaces.
      #
      def normalize_whitespace
        traverse do |element|
          next if element === self

          imported_element = self.class.import element
          next unless imported_element.respond_to? :normalize_whitespace

          imported_element.normalize_whitespace
          element.swap imported_element
        end
      end

      ##
      # Checks the grammar for a match against an input string
      #
      # @param [String] the input string to check for a match with the grammar
      #
      # @return [NoMatch, Match] depending on the result of a match attempt. If a match can be found, it will be returned with appropriate mode/confidence/utterance and interpretation attributes
      #
      def match(other)
        regex = to_regexp
        return NoMatch.new if regex == //
        match = regex.match other
        return NoMatch.new unless match

        Match.new :mode           => mode,
                  :confidence     => dtmf? ? 1 : 0,
                  :utterance      => other,
                  :interpretation => interpret_utterance(other)
      end

      ##
      # Converts the grammar into a regular expression for matching
      #
      # @return [Regexp] a regular expression which is equivalent to the grammar
      #
      def to_regexp
        /^#{regexp_content.join}$/
      end

      def regexp_content
        root_rule.children.map &:regexp_content
      end

      def dtmf?
        mode == :dtmf
      end

      def voice?
        mode == :voice
      end

      def <<(arg)
        raise InvalidChildError, "A Grammar can only accept Rule and Tag as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :language, :base_uri, :mode, :root
      end

      def embed(other)
        raise InvalidChildError, "Embedded grammars must have the same mode" if other.is_a?(self.class) && other.mode != mode
        super
      end

      private

      def has_matching_root_rule?
        !root || root_rule
      end

      def interpret_utterance(utterance)
        utterance
      end

      def split_tokens(element)
        element.to_s.split(/(\".*\")/).reject(&:empty?).map do |string|
          match = string.match /^\"(.*)\"$/
          match ? match[1] : string.split(' ')
        end.flatten
      end
    end # Grammar
  end # GRXML
end # RubySpeech
