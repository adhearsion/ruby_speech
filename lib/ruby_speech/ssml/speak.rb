module RubySpeech
  module SSML
    class Speak < Niceogiri::XML::Node
      include XML::Language

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

      def base_uri
        read_attr :base
      end

      def base_uri=(uri)
        write_attr 'xml:base', uri
      end
    end # Speak
  end # SSML
end # RubySpeech
