module RubySpeech
  module GRXML
    class NoMatch
      def eql?(o)
        o.is_a? self.class
      end
      alias :== :eql?
    end
  end
end
