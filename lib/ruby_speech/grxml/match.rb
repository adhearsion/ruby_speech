module RubySpeech
  module GRXML
    class Match
      attr_accessor :mode, :confidence, :utterance, :interpretation

      def initialize(options = {})
        options.each_pair { |k, v| self.send :"#{k}=", v }
      end

      def eql?(o)
        o.is_a?(self.class) && [:mode, :confidence, :utterance, :interpretation].all? { |f| self.__send__(f) == o.__send__(f) }
      end
      alias :== :eql?
    end
  end
end
