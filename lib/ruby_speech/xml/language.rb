module RubySpeech
  module XML
    module Language
      def language
        self['xml:lang']
      end

      def language=(l)
        self['xml:lang'] = l
      end
    end # Language
  end # XML
end # RubySpeech
