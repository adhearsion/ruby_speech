module RubySpeech::GRXML::Builtins
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
