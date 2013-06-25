require 'active_support/core_ext/class/attribute'

module RubySpeech
  module SSML
    class Element
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

      def to_doc
        document
      end
    end # Element
  end # SSML
end # RubySpeech
