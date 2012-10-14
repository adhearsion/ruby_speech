require 'delegate'

module RubySpeech
  module NLSML
    class Document < SimpleDelegator
      def initialize(xml)
        super
        @xml = xml
      end

      def grammar
        result['grammar']
      end

      def interpretations
        interpretation_nodes.map do |interpretation|
          interpretation_hash_for_interpretation interpretation
        end
      end

      def best_interpretation
        interpretation_hash_for_interpretation interpretation_nodes.first
      end

      def match?
        interpretation_nodes.count > 0
      end

      def ==(other)
        to_xml == other.to_xml
      end

      private

      def input_hash_for_interpretation(interpretation)
        input_element = interpretation.at_xpath 'ns:input', 'ns' => NLSML_NAMESPACE
        { content: input_element.content }.tap do |h|
          h[:mode] = input_element['mode'].to_sym if input_element['mode']
        end
      end

      def instance_hash_for_interpretation(interpretation)
        instance_element = interpretation.at_xpath 'xf:instance', 'xf' => XFORMS_NAMESPACE
        return unless instance_element
        element_children_key_value instance_element
      end

      def element_children_key_value(element)
        element.children.inject({}) do |acc, child|
          acc[child.node_name.to_sym] = case child.children.count
          when 0
            child.content
          when 1
            if child.children.first.is_a?(Nokogiri::XML::Text)
              child.children.first.content
            else
              element_children_key_value child
            end
          else
            element_children_key_value child
          end
          acc
        end
      end

      def interpretation_hash_for_interpretation(interpretation)
        {
          confidence: interpretation['confidence'].to_f/100,
          input: input_hash_for_interpretation(interpretation),
          instance: instance_hash_for_interpretation(interpretation)
        }
      end

      def result
        root
      end

      def interpretation_nodes
        result.xpath('ns:interpretation', 'ns' => NLSML_NAMESPACE).sort_by { |int| -int[:confidence].to_i }
      end
    end
  end
end
