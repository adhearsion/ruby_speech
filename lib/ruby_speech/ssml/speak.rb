module RubySpeech
  module SSML
    class Speak < Niceogiri::XML::Node
      include XML::Language

      def self.new
        super('speak').tap do |new_doc|
          new_doc[:version] = '1.0'
          new_doc.namespace = 'http://www.w3.org/2001/10/synthesis'
          new_doc.language  = "en-US"
        end
      end

      def base_uri
        read_attr :base
      end

      def base_uri=(uri)
        write_attr 'xml:base', uri
      end
    end # Speak
  end # SSML
end # RubySpeech
