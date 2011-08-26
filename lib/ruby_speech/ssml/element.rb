require 'active_support/core_ext/class/inheritable_attributes'

module RubySpeech
  module SSML
    class Element < Niceogiri::XML::Node
      @@registrations = {}

      class_inheritable_accessor :registered_ns, :registered_name

      # Register a new stanza class to a name and/or namespace
      #
      # This registers a namespace that is used when looking
      # up the class name of the object to instantiate when a new
      # stanza is received
      #
      # @param [#to_s] name the name of the node
      #
      def self.register(name)
        self.registered_name = name.to_s
        self.registered_ns = SSML_NAMESPACE
        @@registrations[[self.registered_name, self.registered_ns]] = self
      end

      # Find the class to use given the name and namespace of a stanza
      #
      # @param [#to_s] name the name to lookup
      #
      # @return [Class, nil] the class appropriate for the name
      def self.class_from_registration(name)
        @@registrations[[name.to_s, SSML_NAMESPACE]]
      end

      # Import an XML::Node to the appropriate class
      #
      # Looks up the class the node should be then creates it based on the
      # elements of the XML::Node
      # @param [XML::Node] node the node to import
      # @return the appropriate object based on the node name and namespace
      def self.import(node)
        klass = class_from_registration(node.element_name)
        event = if klass && klass != self
          klass.import node
        else
          new.inherit node
        end
      end

      def self.new(element_name, atts = {}, &block)
        super(element_name) do |new_node|
          atts.each_pair { |k, v| new_node.send :"#{k}=", v }
          block_return = new_node.instance_eval &block if block_given?
          new_node << new_node.encode_special_chars(block_return) if block_return.is_a?(String)
        end
      end

      def children
        super.reject { |c| c.is_a?(Nokogiri::XML::Text) }.map { |c| Element.import c }
      end

      def method_missing(method_name, *args, &block)
        const_name = method_name.to_s.sub('ssml', '').titleize.gsub(' ', '')
        const = SSML.const_get const_name
        if const && self.class::VALID_CHILD_TYPES.include?(const)
          if const == String
            self << encode_special_chars(args.first)
          else
            self << const.new(*args, &block)
          end
        else
          super
        end
      end

      def eql?(o, *args)
        super o, :content, :children, *args
      end
    end # Element
  end # SSML
end # RubySpeech
