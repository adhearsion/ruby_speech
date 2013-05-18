require 'active_support/core_ext/class/attribute'
require 'ruby_speech/xml/node'

module RubySpeech
  module GRXML
    class Element < XML::Node
      def self.namespace
        GRXML_NAMESPACE
      end

      def self.root_element
        Grammar
      end

      def self.module
        GRXML
      end

      alias_method :nokogiri_children, :children

      alias :to_doc :document

      include GenericElement

      def regexp_content # :nodoc:
        "(#{children.map(&:regexp_content).join})"
      end
    end # Element
  end # GRXML
end # RubySpeech
