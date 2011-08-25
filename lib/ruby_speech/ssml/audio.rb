module RubySpeech
  module SSML
    ##
    # The break element is an empty element that controls the pausing or other prosodic boundaries between words. The use of the break element between any pair of words is optional. If the element is not present between words, the synthesis processor is expected to automatically determine a break based on the linguistic context. In practice, the break element is most often used to override the typical automatic behavior of a synthesis processor.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.2.3
    #
    class Audio < Element

      VALID_CHILD_TYPES = [String, Audio, Break, Emphasis, Prosody, SayAs, Voice].freeze

      ##
      # Create a new SSML audio element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [Break] an element for use in an SSML document
      #
      def self.new(atts = {}, &block)
        super 'audio', atts, &block
      end

      ##
      # This attribute is used to indicate the strength of the prosodic break in the speech output. The value "none" indicates that no prosodic break boundary should be outputted, which can be used to prevent a prosodic break which the processor would otherwise produce. The other values indicate monotonically non-decreasing (conceptually increasing) break strength between words. The stronger boundaries are typically accompanied by pauses. "x-weak" and "x-strong" are mnemonics for "extra weak" and "extra strong", respectively.
      #
      # @return [Symbol]
      #
      def src
        read_attr :src
      end

      ##
      # @param [Symbol] the strength. Must be one of VALID_STRENGTHS
      #
      # @raises ArgumentError if s is not one of VALID_STRENGTHS
      #
      def src=(s)
        write_attr :src, s
      end

      def <<(arg)
        raise InvalidChildError, "An Audio can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :src
      end
    end # Audio
  end # SSML
end # RubySpeech
