module RubySpeech
  module GRXML
    class PotentialMatch
      def eql?(o)
        o.is_a? self.class
      end
      alias :== :eql?
    end
  end
end
