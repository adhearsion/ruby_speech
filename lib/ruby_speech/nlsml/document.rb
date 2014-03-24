require 'delegate'

module RubySpeech
  module NLSML
    class Document < SimpleDelegator
      def initialize(xml)
        result = xml.respond_to?(:root) ? xml.root : xml
        unless result.namespace
          result.default_namespace = NLSML_NAMESPACE
          result = Nokogiri::XML.parse(xml.to_xml, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS).root
        end
        super result
      end

      def grammar
        self['grammar']
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
        interpretation_nodes.count > 0 && !nomatch? && !noinput?
      end

      def ==(other)
        to_xml == other.to_xml
      end

      def noinput?
        noinput_elements.any?
      end

      private

      def nomatch?
        nomatch_elements.count >= input_elements.count
      end

      def nomatch_elements
        xpath 'ns:interpretation/ns:input/ns:nomatch', 'ns' => NLSML_NAMESPACE
      end

      def noinput_elements
        xpath 'ns:interpretation/ns:input/ns:noinput', 'ns' => NLSML_NAMESPACE
      end

      def input_elements
        xpath 'ns:interpretation/ns:input', 'ns' => NLSML_NAMESPACE
      end

      def input_hash_for_interpretation(interpretation)
        input_element = interpretation.at_xpath 'ns:input', 'ns' => NLSML_NAMESPACE
        return unless input_element
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
        interpretation.xpath 'ns:instance', 'ns' => NLSML_NAMESPACE
      end

      def element_children_key_value(element)
        return element.children.first.content if element.children.first.is_a?(Nokogiri::XML::Text)
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
          confidence: interpretation['confidence'].to_f,
          input: input_hash_for_interpretation(interpretation),
          instance: instance_hash_for_interpretation(interpretation),
          instances: instances_collection_for_interpretation(interpretation)
        }
      end

      def interpretation_nodes
        nodes = xpath 'ns:interpretation', 'ns' => NLSML_NAMESPACE
        nodes.sort_by { |int| -int[:confidence].to_f }
      end
    end
  end
end
