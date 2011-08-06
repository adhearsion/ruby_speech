module RubySpeech
  module SSML
    ##
    # The Speech Synthesis Markup Language is an XML application. The root element is speak.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.1.1
    #
    class Speak < Element
      include XML::Language

      VALID_CHILD_TYPES = [String, Break, Emphasis, Prosody, SayAs, Voice].freeze

      ##
      # Create a new SSML speak root element
      #
      # @param [Hash] atts Key-value pairs of options mapping to setter methods
      #
      # @return [Speak] an element for use in an SSML document
      #
      def self.new(atts = {}, &block)
        new_node = super('speak', atts)
        new_node[:version] = '1.0'
        new_node.namespace = 'http://www.w3.org/2001/10/synthesis'
        new_node.language ||= "en-US"
        new_node.instance_eval &block if block_given?
        new_node
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

      def <<(arg)
        raise InvalidChildError, "A Speak can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def to_doc
        Nokogiri::XML::Document.new.tap do |doc|
          doc << self
        end
      end

      def +(other)
        self.class.new(:base_uri => base_uri).tap do |new_speak|
          new_speak.children = self.children + other.children
          new_speak.children.each { |c| c.namespace = new_speak.namespace }
        end
      end

      def eql?(o)
        super o, :language, :base_uri
      end
    end # Speak
  end # SSML
end # RubySpeech
