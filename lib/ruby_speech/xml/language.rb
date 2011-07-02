module RubySpeech
  module XML
    module Language
      def language
        read_attr :lang
      end

      def language=(l)
        write_attr 'xml:lang', l
      end
    end # Language
  end # XML
end # RubySpeech
