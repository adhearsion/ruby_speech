module RubySpeech
  module SSML
    ##
    # The audio element supports the insertion of recorded audio files (see Appendix A for required formats) and the insertion of other audio formats in conjunction with synthesized speech output. The audio element may be empty. If the audio element is not empty then the contents should be the marked-up text to be spoken if the audio document is not available. The alternate content may include text, speech markup, desc elements, or other audio elements. The alternate content may also be used when rendering the document to non-audible output and for accessibility (see the desc element). The required attribute is src, which is the URI of a document with an appropriate MIME type.
    #
    # An audio element is successfully rendered:
    #   * If the referenced audio source is played, or
    #   * If the synthesis processor is unable to execute #1 but the alternative content is successfully rendered, or
    #   * If the processor can detect that text-only output is required and the alternative content is successfully rendered.
    #
    # Deciding which conditions result in the alternative content being rendered is processor-dependent. If the audio element is not successfully rendered, a synthesis processor should continue processing and should notify the hosting environment. The processor may determine after beginning playback of an audio source that the audio cannot be played in its entirety. For example, encoding problems, network disruptions, etc. may occur. The processor may designate this either as successful or unsuccessful rendering, but it must document this behavior.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.3.1
    #
    class Audio < Element

      register :audio

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String, Audio, Break, Emphasis, P, Prosody, S, SayAs, Voice].freeze

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
      # The URI of a document with an appropriate MIME type
      #
      # @return [String]
      #
      def src
        read_attr :src
      end

      ##
      # @param [String] the source. Must be a valid URI
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
