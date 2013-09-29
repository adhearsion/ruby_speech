require 'spec_helper'

describe RubySpeech::GRXML::Builtins do
  describe "boolean" do
    subject(:grammar) { described_class.boolean }

    it { should max_match('1').and_interpret_as('true') }
    it { should max_match('2').and_interpret_as('false') }

    it { should not_match('0') }
    it { should not_match('3') }
    it { should not_match('10') }
  end

  describe "currency" do
    subject(:grammar) { described_class.currency }

    it { should max_match('1*01').and_interpret_as('dtmf-1 dtmf-star dtmf-0 dtmf-1') }
    it { should max_match('01*00').and_interpret_as('dtmf-0 dtmf-1 dtmf-star dtmf-0 dtmf-0') }
    it { should max_match('100000000000*00').and_interpret_as('dtmf-1 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-star dtmf-0 dtmf-0') }
    it { should max_match('0*08').and_interpret_as('dtmf-0 dtmf-star dtmf-0 dtmf-8') }
    it { should max_match('*59').and_interpret_as('dtmf-star dtmf-5 dtmf-9') }

    it { should match('0').and_interpret_as('dtmf-0') }
    it { should match('0*0').and_interpret_as('dtmf-0 dtmf-star dtmf-0') }
    it { should match('10*5').and_interpret_as('dtmf-1 dtmf-0 dtmf-star dtmf-5') }
    it { should match('123').and_interpret_as('dtmf-1 dtmf-2 dtmf-3') }
    it { should match('123*').and_interpret_as('dtmf-1 dtmf-2 dtmf-3 dtmf-star') }

    it { should not_match('#') }
  end
end
