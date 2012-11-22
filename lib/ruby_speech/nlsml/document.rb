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
        input_element ||= interpretation.at_xpath 'input'
        { content: input_element.content }.tap do |h|
          h[:mode] = input_element['mode'].to_sym if input_element['mode']
        end
      end

      def instance_hash_for_interpretation(interpretation)
        instances = instance_elements interpretation
        return unless instances.any?
        element_children_key_value instances.first
      end

      def instances_collection_for_interpretation(interpretation)
        instances = instance_elements interpretation
        instances.map do |instance|
          element_children_key_value instance
        end
      end

      def instance_elements(interpretation)
        instance_elements = interpretation.xpath 'xf:instance', 'xf' => XFORMS_NAMESPACE
        instance_elements += interpretation.xpath 'ns:instance', 'ns' => NLSML_NAMESPACE
        instance_elements += interpretation.xpath 'instance'
        instance_elements
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
          instance: instance_hash_for_interpretation(interpretation),
          instances: instances_collection_for_interpretation(interpretation)
        }
      end

      def result
        root
      end

      def interpretation_nodes
        nodes = result.xpath 'ns:interpretation', 'ns' => NLSML_NAMESPACE
        nodes += result.xpath 'interpretation'
        nodes.sort_by { |int| -int[:confidence].to_i }
      end
    end
  end
end
