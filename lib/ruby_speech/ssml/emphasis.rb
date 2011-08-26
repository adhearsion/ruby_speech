module RubySpeech
  module SSML
    ##
    # The emphasis element requests that the contained text be spoken with emphasis (also referred to as prominence or stress). The synthesis processor determines how to render emphasis since the nature of emphasis differs between languages, dialects or even voices.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.2.2
    #
    class Emphasis < Element

      register :emphasis

      VALID_LEVELS = [:strong, :moderate, :none, :reduced].freeze
      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String, Audio, Break, Emphasis, Prosody, SayAs, Voice].freeze

      ##
      # Create a new SSML emphasis element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [Emphasis] an element for use in an SSML document
      #
      def self.new(atts = {}, &block)
        super 'emphasis', atts, &block
      end

      ##
      # Indicates the strength of emphasis to be applied. Defined values are "strong", "moderate", "none" and "reduced". The default level is "moderate". The meaning of "strong" and "moderate" emphasis is interpreted according to the language being spoken (languages indicate emphasis using a possible combination of pitch change, timing changes, loudness and other acoustic differences). The "reduced" level is effectively the opposite of emphasizing a word. For example, when the phrase "going to" is reduced it may be spoken as "gonna". The "none" level is used to prevent the synthesis processor from emphasizing words that it might typically emphasize. The values "none", "moderate", and "strong" are monotonically non-decreasing in strength.
      #
      # @return [Symbol]
      #
      def level
        read_attr :level, :to_sym
      end

      ##
      # @param [Symbol] l the level. Must be one of VALID_LEVELS
      #
      # @raises ArgumentError if l is not one of VALID_LEVELS
      #
      def level=(l)
        raise ArgumentError, "You must specify a valid level (#{VALID_LEVELS.map(&:inspect).join ', '})" unless VALID_LEVELS.include? l
        write_attr :level, l
      end

      def <<(arg)
        raise InvalidChildError, "An Emphasis can only accept String, Audio, Break, Emphasis, Mark, Phoneme, Prosody, SayAs, Sub, Voice as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :level
      end
    end # Emphasis
  end # SSML
end # RubySpeech
