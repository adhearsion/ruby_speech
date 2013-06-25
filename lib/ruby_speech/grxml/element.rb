require 'active_support/core_ext/class/attribute'
require 'ruby_speech/generic_element'

module RubySpeech
  module GRXML
    class Element
      def self.namespace
        GRXML_NAMESPACE
      end

      def self.root_element
        Grammar
      end

      def self.module
        GRXML
      end

      include GenericElement

      def to_doc
        document
      end

      def regexp_content # :nodoc:
        "(#{children.map(&:regexp_content).join})"
      end
    end # Element
  end # GRXML
end # RubySpeech
