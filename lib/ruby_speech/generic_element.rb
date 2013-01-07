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
        node = Nokogiri::XML.parse(node, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS).root unless node.is_a?(Nokogiri::XML::Node)
        return node.content if node.is_a?(Nokogiri::XML::Text)
        klass = class_from_registration node.node_name
        if klass && klass != self
          klass.import node
        else
          new.inherit node
        end
      end

      def new(atts = {}, &block)
        super(self.registered_name, nil, self.namespace) do |new_node|
          (self.defaults || {}).merge(atts).each_pair { |k, v| new_node.send :"#{k}=", v }
          block_return = new_node.eval_dsl_block &block
          new_node.string block_return if block_return.is_a?(String) && block_return.present?
        end
      end
    end

    attr_writer :parent

    def parent
      @parent || super
    end

    def inherit(node)
      self.parent = node.parent
      super
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
      self.class.new(:base_uri => base_uri).tap do |new_element|
        (self.children + other.children).each do |child|
          new_element << child
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
        expression = type.to_s

        expression << '[' << attributes.inject([]) do |h, (key, value)|
          h << "@#{key}='#{value}'"
        end.join(',') << ']' if attributes

        if namespace_href
          xpath "ns:#{expression}", :ns => namespace_href
        else
          xpath expression
        end
      else
        super()
      end.map { |c| self.class.import c }
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
        raise ArgumentError, "Can only embed a String or a #{self.class.module} element, not a #{other}"
      end
    end

    def string(other)
      self << Nokogiri::XML::Text.new(other, document)
    end

    def method_missing(method_name, *args, &block)
      const_name = method_name.to_s.sub('ssml', '').titleize.gsub(' ', '')
      if self.class.module.const_defined?(const_name)
        const = self.class.module.const_get const_name
        embed const.new(*args, &block)
      elsif @block_binding && @block_binding.respond_to?(method_name)
        @block_binding.send method_name, *args, &block
      else
        super
      end
    end

    def clone
      GRXML.import to_xml
    end

    def traverse(&block)
      nokogiri_children.each { |j| j.traverse &block }
      block.call self
    end

    def eql?(o, *args)
      super o, :content, :children, *args
    end
  end # Element
end # RubySpeech
