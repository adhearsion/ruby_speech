require 'active_support/core_ext/class/attribute'
require 'ruby_speech/xml/node'

module RubySpeech
  module SSML
    class Element < XML::Node
      def self.namespace
        SSML_NAMESPACE
      end

      def self.root_element
        Speak
      end

      def self.module
        SSML
      end

      include GenericElement

      alias :to_doc :document
    end # Element
  end # SSML
end # RubySpeech
