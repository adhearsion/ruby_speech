module RubySpeech
  module SSML
    class Emphasis < Niceogiri::XML::Node
      VALID_LEVELS = [:strong, :moderate, :none, :reduced].freeze

      def self.new
        super('emphasis')
      end

      def level
        read_attr :level, :to_sym
      end

      def level=(l)
        raise ArgumentError, "You must specify a valid level (#{VALID_LEVELS.map(&:inspect).join ', '})" unless VALID_LEVELS.include? l
        write_attr :level, l
      end
    end # Emphasis
  end # SSML
end # RubySpeech
