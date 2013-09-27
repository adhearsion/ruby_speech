module RubySpeech::GRXML::Builtins
  #
  # Create a grammar for interpreting a monetary value. Uses '*' as the decimal point.
  # Matches any number of digits, followed by a '*' and exactly two more digits.
  #
  # @return [RubySpeech::GRXML::Grammar] a grammar for interpreting a monetary value.
  #
  def self.currency
    RubySpeech::GRXML.draw mode: :dtmf, root: 'currency' do
      rule id: 'currency', scope: 'public' do
        item repeat: '0-' do
          ruleref uri: '#digit'
        end
        item { '*' }
        item repeat: '2' do
          ruleref uri: '#digit'
        end
      end

      rule id: 'digit' do
        one_of do
          0.upto(9) { |d| item { d.to_s } }
        end
      end
    end
  end
end
