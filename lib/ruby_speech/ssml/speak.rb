module RubySpeech
  module SSML
    ##
    # The Speech Synthesis Markup Language is an XML application. The root element is speak.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.1.1
    #
    class Speak < Niceogiri::XML::Node
      include XML::Language

      ##
      # Create a new SSML speak root element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [Speak] an element for use in an SSML document
      #
      def self.new(atts = {})
        super('speak') do |new_node|
          new_node[:version] = '1.0'
          new_node.namespace = 'http://www.w3.org/2001/10/synthesis'
          new_node.language  = "en-US"

          atts.each_pair do |k, v|
            new_node.send :"#{k}=", v
          end
        end
      end

      ##
      # @return [String] the base URI to which relative URLs are resolved
      #
      def base_uri
        read_attr :base
      end

      ##
      # @param [String] uri the base URI to which relative URLs are resolved
      #
      def base_uri=(uri)
        write_attr 'xml:base', uri
      end

      def eql?(o)
        super o, :language, :base_uri, :content
      end
    end # Speak
  end # SSML
end # RubySpeech
