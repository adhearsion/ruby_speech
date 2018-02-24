require 'ruby_speech/generic_element'

module RubySpeech
  module SSML
    class Element
      def self.namespace
        SSML_NAMESPACE
      end

      def self.root_element
        Speak
      end

      def self.module
        SSML
      end

      include GenericElement

      def to_doc
        document
      end

      private

      def get_time_attribute(key)
        value = read_attr(key)

        if value.nil?
          nil
        elsif value.end_with?('ms')
          value.to_f / 1000
        else
          value.to_f
        end
      end

      def set_time_attribute(key, value)
        raise ArgumentError, "You must specify a valid #{key} (positive float value in seconds)" unless value.is_a?(Numeric) && value >= 0
        self[key] = value == value.round ? "#{value.to_i}s" : "#{(value * 1000).to_i}ms"
      end
    end # Element
  end # SSML
end # RubySpeech
