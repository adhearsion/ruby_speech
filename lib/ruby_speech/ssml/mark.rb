require 'ruby_speech/ssml/element'

module RubySpeech
  module SSML
    ##
    # A mark element is an empty element that places a marker into the text/tag sequence. It has one required attribute, name, which is of type xsd:token [SCHEMA2 §3.3.2]. The mark element can be used to reference a specific location in the text/tag sequence, and can additionally be used to insert a marker into an output stream for asynchronous notification. When processing a mark element, a synthesis processor must do one or both of the following:
    #
    # * inform the hosting environment with the value of the name attribute and with information allowing the platform to retrieve the corresponding position in the rendered output.
    # * when audio output of the SSML document reaches the mark, issue an event that includes the required name attribute of the element. The hosting environment defines the destination of the event.
    #
    # The mark element does not affect the speech output process.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.3.2
    #
    class Mark < Element

      register :mark

      ##
      # This attribute is a token by which to reference the mark
      #
      # @return [String]
      #
      def name
        read_attr :name
      end

      ##
      # @param [String] the name token
      #
      def name=(other)
        self[:name] = other
      end

      def <<(*args)
        raise InvalidChildError, "A Mark cannot contain children"
        super
      end

      def eql?(o)
        super o, :name
      end
    end # Mark
  end # SSML
end # RubySpeech
