require 'active_support/core_ext/class/attribute'

module RubySpeech
  module GRXML
    class Element < Niceogiri::XML::Node
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

      include GenericElement

      def regexp_content # :nodoc:
        children.map(&:regexp_content).join
      end

      def potential_match?(other)
        false
      end

      def max_input_length
        0
      end

      def longest_potential_match(input)
        input.dup.tap do |longest_input|
          begin
            return longest_input if potential_match? longest_input
            longest_input.chop!
          end until longest_input.length.zero?
        end
      end
    end # Element
  end # GRXML
end # RubySpeech
