module RubySpeech::GRXML::Builtins
  #
  # Create a grammar for interpreting a monetary value. Uses '*' as the decimal point.
  # Matches any number of digits, optionally followed by a '*' and up to two more digits.
  #
  # @return [RubySpeech::GRXML::Grammar] a grammar for interpreting a monetary value.
  #
  def self.currency
    RubySpeech::GRXML.draw mode: :dtmf, root: 'currency' do
      rule id: 'currency', scope: 'public' do
        item repeat: '0-' do
          ruleref uri: '#digit'
        end
        item repeat: '0-1' do
          item { '*' }
          item repeat: '0-2' do
            ruleref uri: '#digit'
          end
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
