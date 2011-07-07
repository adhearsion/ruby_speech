module RubySpeech
  module SSML
    ##
    # The break element is an empty element that controls the pausing or other prosodic boundaries between words. The use of the break element between any pair of words is optional. If the element is not present between words, the synthesis processor is expected to automatically determine a break based on the linguistic context. In practice, the break element is most often used to override the typical automatic behavior of a synthesis processor.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.2.3
    #
    class Break < Element

      VALID_STRENGTHS = [:none, :'x-weak', :weak, :medium, :strong, :'x-strong'].freeze

      ##
      # Create a new SSML break element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [Break] an element for use in an SSML document
      #
      def self.new(atts = {}, &block)
        super 'break', atts, &block
      end

      ##
      # This attribute is used to indicate the strength of the prosodic break in the speech output. The value "none" indicates that no prosodic break boundary should be outputted, which can be used to prevent a prosodic break which the processor would otherwise produce. The other values indicate monotonically non-decreasing (conceptually increasing) break strength between words. The stronger boundaries are typically accompanied by pauses. "x-weak" and "x-strong" are mnemonics for "extra weak" and "extra strong", respectively.
      #
      # @return [Symbol]
      #
      def strength
        read_attr :strength, :to_sym
      end

      ##
      # @param [Symbol] the strength. Must be one of VALID_STRENGTHS
      #
      # @raises ArgumentError if s is not one of VALID_STRENGTHS
      #
      def strength=(s)
        raise ArgumentError, "You must specify a valid strength (#{VALID_STRENGTHS.map(&:inspect).join ', '})" unless VALID_STRENGTHS.include? s
        write_attr :strength, s
      end

      ##
      # Indicates the duration of a pause to be inserted in the output in seconds or milliseconds. It follows the time value format from the Cascading Style Sheets Level 2 Recommendation [CSS2], e.g. "250ms", "3s".
      #
      # @return [Float]
      #
      def time
        read_attr :time, :to_f
      end

      ##
      # @param [Numeric] t the time as a positive value in seconds
      #
      # @raises ArgumentError if t is nota positive numeric value
      #
      def time=(t)
        raise ArgumentError, "You must specify a valid time (positive float value in seconds)" unless t.is_a?(Numeric) && t >= 0
        write_attr :time, "#{t}s"
      end

      def <<(*args)
        raise InvalidChildError, "A Break cannot contain children"
        super
      end

      def eql?(o)
        super o, :strength, :time
      end
    end # Break
  end # SSML
end # RubySpeech
