module RubySpeech
  module SSML
    class Speak < Niceogiri::XML::Node
      def self.new
        super('speak').tap do |new_doc|
          new_doc.namespace   = 'http://www.w3.org/2001/10/synthesis'
          new_doc[:version]   = '1.0'
          new_doc['xml:lang'] = "en-US"
        end
      end
    end # Document
  end # SSML
end # RubySpeech
