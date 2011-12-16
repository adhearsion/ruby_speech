require 'active_support/core_ext/class/attribute'

module RubySpeech
  module SSML
    class Element < Niceogiri::XML::Node
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
    end # Element
  end # SSML
end # RubySpeech
