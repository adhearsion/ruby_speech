module RubySpeech
  module XML
    module Language
      def language
        read_attr :lang
      end

      def language=(l)
        self['xml:lang'] = l
      end
    end # Language
  end # XML
end # RubySpeech
