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

      def set_time_attribute(key, value)
        raise ArgumentError, "You must specify a valid #{key} (positive float value in seconds)" unless value.is_a?(Numeric) && value >= 0
        self[key] = "#{value}s"
      end
    end # Element
  end # SSML
end # RubySpeech
