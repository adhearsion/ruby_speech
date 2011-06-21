module RubySpeech
  module SSML
    class Voice < Niceogiri::XML::Node
      include XML::Language

      VALID_GENDERS = [:male, :female, :neutral].freeze

      def self.new(atts = {})
        super('voice') do |new_node|
          atts.each_pair do |k, v|
            new_node.send :"#{k}=", v
          end
        end
      end

      def gender
        read_attr :gender, :to_sym
      end

      def gender=(g)
        raise ArgumentError, "You must specify a valid gender (#{VALID_GENDERS.map(&:inspect).join ', '})" unless VALID_GENDERS.include? g
        write_attr :gender, g
      end

      def age
        read_attr :age, :to_i
      end

      def age=(i)
        raise ArgumentError, "You must specify a valid age (non-negative integer)" unless i.is_a?(Integer) && i >= 0
        write_attr :age, i
      end

      def variant
        read_attr :variant, :to_i
      end

      def variant=(i)
        raise ArgumentError, "You must specify a valid variant (positive integer)" unless i.is_a?(Integer) && i > 0
        write_attr :variant, i
      end

      def name
        names = read_attr :name
        return unless names
        names = names.split ' '
        case names.count
        when 0 then nil
        when 1 then names.first
        else names
        end
      end

      def name=(n)
        n = n.join(' ') if n.is_a? Array
        write_attr :name, n
      end
    end # Voice
  end # SSML
end # RubySpeech
