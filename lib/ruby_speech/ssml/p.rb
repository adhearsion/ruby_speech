module RubySpeech
  module SSML
    ##
    # A p element represents a paragraph.
    # The use of p elements is optional. Where text occurs without an enclosing p element the synthesis processor should attempt to determine the structure using language-specific knowledge of the format of plain text.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.1.7
    #
    class P < Element

      register :p

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String, Audio, Break, Emphasis, Mark, Prosody, S, SayAs, Voice].freeze

      ##
      # Create a new SSML p element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [P] a p for use in an SSML document
      #
      def self.new(atts = {}, &block)
        super 'p', atts, &block
      end

      def <<(arg)
        raise InvalidChildError, "A P can only accept String, Audio, Break, Emphasis, Mark, Phoneme, Prosody, SayAs, Sub, S, Voice as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :language
      end
    end # P
  end # SSML
end # RubySpeech
