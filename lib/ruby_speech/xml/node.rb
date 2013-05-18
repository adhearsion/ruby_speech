module RubySpeech
  module XML

    # Base XML Node
    # All XML classes subclass Node - it allows the addition of helpers
    class Node < Nokogiri::XML::Node
      # Create a new Node object
      #
      # @param [String, nil] name the element name
      # @param [XML::Document, nil] doc the document to attach the node to. If
      # not provided one will be created
      # @return a new object with the name and namespace
      def self.new(name = nil, doc = nil, ns = nil)
        super(name.to_s, (doc || Nokogiri::XML::Document.new)).tap do |node|
          node.document.root = node unless doc
          node.namespace = ns if ns
        end
      end

      # Helper method to read an attribute
      #
      # @param [#to_sym] attr_name the name of the attribute
      # @param [String, Symbol, nil] to_call the name of the method to call on
      # the returned value
      # @return nil or the value
      def read_attr(attr_name, to_call = nil)
        val = self[attr_name.to_sym]
        val && to_call ? val.__send__(to_call) : val
      end

      alias_method :attr_set, :[]=
      # Override Nokogiri's attribute setter to add the ability to kill an attribute
      # by setting it to nil and to be able to lookup an attribute by symbol
      #
      # @param [#to_s] name the name of the attribute
      # @param [#to_s, nil] value the new value or nil to remove it
      def []=(name, value)
        name = name.to_s
        if value.nil?
          remove_attribute name
        else
          value = value.is_a?(Array) ? value.join : value
          attr_set name, value.to_s
        end
      end

      # Helper method to write a value to an attribute
      #
      # @param [#to_sym] attr_name the name of the attribute
      # @param [#to_s] value the value to set the attribute to
      def write_attr(attr_name, value, to_call = nil)
        self[attr_name.to_sym] = value && to_call ? value.__send__(to_call) : value
      end

      # @private
      alias_method :nokogiri_namespace=, :namespace=
      # Attach a namespace to the node
      #
      # @overload namespace=(ns)
      #   Attach an already created XML::Namespace
      #   @param [XML::Namespace] ns the namespace object
      # @overload namespace=(ns)
      #   Create a new namespace and attach it
      #   @param [String] ns the namespace uri
      # @overload namespace=(namespaces)
      #   Createa and add new namespaces from a hash
      #   @param [Hash] namespaces a hash of prefix => uri pairs
      def namespace=(namespaces)
        case namespaces
        when Nokogiri::XML::Namespace
          self.nokogiri_namespace = namespaces
        when String
          ns = self.add_namespace nil, namespaces
          self.nokogiri_namespace = ns
        when Hash
          self.add_namespace nil, ns if ns = namespaces.delete(nil)
          namespaces.each do |p, n|
            ns = self.add_namespace p, n
            self.nokogiri_namespace = ns
          end
        end
      end

      # Helper method to get the node's namespace
      #
      # @return [XML::Namespace, nil] The node's namespace object if it exists
      def namespace_href
        namespace.href if namespace
      end

      # Inherit the attributes and children of an XML::Node
      #
      # @param [XML::Node] node the node to inherit
      # @return [self]
      def inherit(node)
        inherit_namespaces node
        inherit_attrs node.attributes
        inherit_children node
        self
      end

      def inherit_namespaces(node)
        node.namespace_definitions.each do |ns|
          add_namespace ns.prefix, ns.href
        end
        self.namespace = node.namespace.href if node.namespace
      end

      # Inherit a set of attributes
      #
      # @param [Hash] attrs a hash of attributes to set on the node
      # @return [self]
      def inherit_attrs(attrs)
        attrs.each do |name, value|
          attr_name = value.namespace && value.namespace.prefix ? [value.namespace.prefix, name].join(':') : name
          self.write_attr attr_name, value
        end
        self
      end

      def inherit_children(node)
        node.children.each do |c|
          self << (n = c.dup)
          if c.respond_to?(:namespace) && c.namespace
            ns = n.add_namespace c.namespace.prefix, c.namespace.href
            n.namespace = ns
          end
        end
      end

      # The node as XML
      #
      # @return [String] XML representation of the node
      def inspect
        self.to_xml
      end

      # Check that a set of fields are equal between nodes
      #
      # @param [Node] other the other node to compare against
      # @param [*#to_s] fields the set of fields to compare
      # @return [Fixnum<-1,0,1>]
      def eql?(o, *fields)
        o.is_a?(self.class) && fields.all? { |f| self.__send__(f) == o.__send__(f) }
      end

      # @private
      def ==(o)
        eql?(o)
      end
    end
  end
end
