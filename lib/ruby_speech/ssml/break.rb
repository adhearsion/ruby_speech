module RubySpeech
  module SSML
    class Break < Niceogiri::XML::Node
      VALID_STRENGTHS = [:none, :'x-weak', :weak, :medium, :strong, :'x-strong'].freeze

      def self.new(atts = {})
        super('break') do |new_node|
          atts.each_pair do |k, v|
            new_node.send :"#{k}=", v
          end
        end
      end

      def strength
        read_attr :strength, :to_sym
      end

      def strength=(s)
        raise ArgumentError, "You must specify a valid strength (#{VALID_STRENGTHS.map(&:inspect).join ', '})" unless VALID_STRENGTHS.include? s
        write_attr :strength, s
      end

      def time
        read_attr :time, :to_i
      end

      def time=(t)
        raise ArgumentError, "You must specify a valid time (positive float value in seconds)" unless t.is_a?(Numeric) && t >= 0
        write_attr :time, "#{t}s"
      end
    end # Break
  end # SSML
end # RubySpeech
