require 'active_support/core_ext/class/attribute'

module RubySpeech
  module GenericElement

    def self.included(klass)
      klass.class_attribute :registered_ns, :registered_name, :defaults
      klass.extend ClassMethods
    end

    module ClassMethods
      @@registrations = {}

      # Register a new stanza class to a name and/or namespace
      #
      # This registers a namespace that is used when looking
      # up the class name of the object to instantiate when a new
      # stanza is received
      #
      # @param [#to_s] name the name of the node
      #
      def register(name)
        self.registered_name = name.to_s
        self.registered_ns = namespace
        @@registrations[[self.registered_name, self.registered_ns]] = self
      end

      # Find the class to use given the name and namespace of a stanza
      #
      # @param [#to_s] name the name to lookup
      #
      # @return [Class, nil] the class appropriate for the name
      def class_from_registration(name)
        @@registrations[[name.to_s, namespace]]
      end

      # Import an XML::Node to the appropriate class
      #
      # Looks up the class the node should be then creates it based on the
      # elements of the XML::Node
      # @param [XML::Node] node the node to import
      # @return the appropriate object based on the node name and namespace
      def import(node)
        node = Nokogiri::XML.parse(node, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS).root unless node.is_a?(Nokogiri::XML::Node) || node.is_a?(GenericElement)
        return node.content if node.is_a?(Nokogiri::XML::Text)
        klass = class_from_registration node.node_name
        if klass && klass != self
          klass.import node
        else
          new(node.document).inherit node
        end
      end
    end

    def initialize(doc, atts = nil, &block)
      @doc = doc
      build atts, &block if atts || block_given?
    end

    attr_writer :parent

    def node
      @node || create_node
    end

    def parent
      @parent || super
    end

    def inherit(node)
      self.parent = node.parent
      @node = node
      self
    end

    def build(atts, &block)
      mass_assign atts
      block_return = eval_dsl_block &block
      string block_return if block_return.is_a?(String) && !block_return.length.zero?
    end

    def version
      read_attr :version
    end

    def version=(other)
      self[:version] = other
    end

    ##
    # @return [String] the base URI to which relative URLs are resolved
    #
    def base_uri
      read_attr 'xml:base'
    end

    ##
    # @param [String] uri the base URI to which relative URLs are resolved
    #
    def base_uri=(uri)
      self['xml:base'] = uri
    end

    def +(other)
      new_doc = Nokogiri::XML::Document.new
      self.class.new(new_doc).tap do |new_element|
        new_doc.root = new_element.node
        string_types = [String, Nokogiri::XML::Text]
        include_spacing = string_types.include?(self.nokogiri_children.last.class) && string_types.include?(other.nokogiri_children.first.class)
        if Nokogiri.jruby?
          new_element.add_child self.clone.nokogiri_children
          new_element << " " if include_spacing
          new_element.add_child other.clone.nokogiri_children
        else
          # TODO: This is yucky because it requires serialization
          new_element.add_child self.nokogiri_children.to_xml
          new_element << " " if include_spacing
          new_element.add_child other.nokogiri_children.to_xml
        end
      end
    end

    def eval_dsl_block(&block)
      return unless block_given?
      @block_binding = eval "self", block.binding
      instance_eval &block
    end

    def children(type = nil, attributes = nil)
      if type
        expression = namespace_href ? 'ns:' : ''
        expression << type.to_s

        expression << '[' << attributes.inject([]) do |h, (key, value)|
          h << "@#{key}='#{value}'"
        end.join(',') << ']' if attributes

        xpath expression, :ns => self.class.namespace
      else
        super()
      end.map { |c| self.class.import c }
    end

    def nokogiri_children
      node.children
    end

    def <<(other)
      case other
      when GenericElement
        super other.node
      when String
        string other
      else
        super other
      end
    end

    def embed(other)
      case other
      when String
        string other
      when self.class.root_element
        other.children.each do |child|
          self << child
        end
      when self.class.module::Element
        self << other
      else
        raise ArgumentError, "Can only embed a String or a #{self.class.module} element, not a #{other.class}"
      end
    end

    def string(other)
      self << Nokogiri::XML::Text.new(other.to_s, document)
    end

    def clone
      self.class.import to_xml
    end

    def traverse(&block)
      nokogiri_children.each { |j| j.traverse &block }
      block.call self
    end

    # Helper method to read an attribute
    #
    # @param [#to_sym] attr_name the name of the attribute
    # @param [String, Symbol, nil] to_call the name of the method to call on
    # the returned value
    # @return nil or the value
    def read_attr(attr_name, to_call = nil)
      val = self[attr_name]
      val && to_call ? val.__send__(to_call) : val
    end

    # Helper method to write a value to an attribute
    #
    # @param [#to_sym] attr_name the name of the attribute
    # @param [#to_s] value the value to set the attribute to
    def write_attr(attr_name, value, to_call = nil)
      self[attr_name] = value && to_call ? value.__send__(to_call) : value
    end

    # Attach a namespace to the node
    #
    # @overload namespace=(ns)
    #   Attach an already created XML::Namespace
    #   @param [XML::Namespace] ns the namespace object
    # @overload namespace=(ns)
    #   Create a new namespace and attach it
    #   @param [String] ns the namespace uri
    def namespace=(namespaces)
      case namespaces
      when Nokogiri::XML::Namespace
        super namespaces
      when String
        ns = self.add_namespace nil, namespaces
        super ns
      end
    end

    # Helper method to get the node's namespace
    #
    # @return [XML::Namespace, nil] The node's namespace object if it exists
    def namespace_href
      namespace.href if namespace
    end

    # The node as XML
    #
    # @return [String] XML representation of the node
    def inspect
      self.to_xml
    end

    def to_s
      to_xml
    end

    # Check that a set of fields are equal between nodes
    #
    # @param [Node] other the other node to compare against
    # @param [*#to_s] fields the set of fields to compare
    # @return [Fixnum<-1,0,1>]
    def eql?(o, *fields)
      o.is_a?(self.class) && ([:content, :children] + fields).all? { |f| self.__send__(f) == o.__send__(f) }
    end

    # @private
    def ==(o)
      eql?(o)
    end

    def create_node
      @node = Nokogiri::XML::Node.new self.class.registered_name, @doc
      mass_assign self.class.defaults
      @node
    end

    def mass_assign(attrs)
      attrs.each_pair { |k, v| send :"#{k}=", v } if attrs
    end

    def method_missing(method_name, *args, &block)
      if node.respond_to?(method_name)
        return node.send method_name, *args, &block
      end

      const_name = method_name.to_s.sub('ssml_', '').gsub('_', '-')
      if const = self.class.class_from_registration(const_name)
        embed const.new(self.document, *args, &block)
      elsif @block_binding && @block_binding.respond_to?(method_name)
        @block_binding.send method_name, *args, &block
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      node.respond_to?(method_name, include_private) || super
    end
  end # Element
end # RubySpeech
