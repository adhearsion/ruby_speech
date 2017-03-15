require 'spec_helper'

describe RubySpeech::GRXML::Builtins do
  describe "boolean" do
    subject(:grammar) { described_class.boolean }

    it { should max_match('1').and_interpret_as('true') }
    it { should max_match('2').and_interpret_as('false') }

    it { should not_match('0') }
    it { should not_match('3') }
    it { should not_match('10') }

    context "with the true/false digits parameterized" do
      subject { described_class.boolean y: 3, n: 7 }

      it { should max_match('3').and_interpret_as('true') }
      it { should max_match('7').and_interpret_as('false') }

      it { should not_match('1') }
      it { should not_match('2') }
      it { should not_match('4') }

      context "both the same" do
        it "should raise ArgumentError" do
          expect { described_class.boolean y: '1', n: 1 }.to raise_error(ArgumentError, /same/)
        end
      end
    end
  end

  describe "date" do
    subject(:grammar) { described_class.date }

    it { should max_match('20130929').and_interpret_as('dtmf-2 dtmf-0 dtmf-1 dtmf-3 dtmf-0 dtmf-9 dtmf-2 dtmf-9') }

    it { should potentially_match('130929') }
    it { should potentially_match('0929') }
    it { should potentially_match('29') }
    it { should potentially_match('1') }
  end

  describe "digits" do
    subject(:grammar) { described_class.digits }

    it { should match('1').and_interpret_as('dtmf-1') }
    it { should match('123').and_interpret_as('dtmf-1 dtmf-2 dtmf-3') }
    it { should match('1').and_interpret_as('dtmf-1') }

    context "with a minimum length" do
      subject { described_class.digits minlength: 3 }

      it { should match('123').and_interpret_as('dtmf-1 dtmf-2 dtmf-3') }
      it { should match('1234567890').and_interpret_as('dtmf-1 dtmf-2 dtmf-3 dtmf-4 dtmf-5 dtmf-6 dtmf-7 dtmf-8 dtmf-9 dtmf-0') }

      it { should potentially_match('1') }
      it { should potentially_match('11') }
      it { should potentially_match('4') }
    end

    context "with a maximum length" do
      subject { described_class.digits maxlength: 3 }

      it { should match('1').and_interpret_as('dtmf-1') }
      it { should match('12').and_interpret_as('dtmf-1 dtmf-2') }
      it { should match('123').and_interpret_as('dtmf-1 dtmf-2 dtmf-3') }

      it { should not_match('1111') }
      it { should not_match('1111111') }
    end

    context "with an absolute length" do
      subject { described_class.digits length: 3 }

      it { should max_match('123').and_interpret_as('dtmf-1 dtmf-2 dtmf-3') }
      it { should max_match('111').and_interpret_as('dtmf-1 dtmf-1 dtmf-1') }

      it { should potentially_match('1') }
      it { should potentially_match('12') }

      it { should not_match('1234') }
      it { should not_match('12345') }
    end

    context "when the min and max lengths are swapped" do
      it "should raise ArgumentError" do
        expect { described_class.digits minlength: 5, maxlength: 2 }.to raise_error(ArgumentError, /repeat/)
      end
    end

    context "when the length and minlength are specified" do
      it "should raise ArgumentError" do
        expect { described_class.digits minlength: 5, length: 5 }.to raise_error(ArgumentError, /absolute length/)
      end
    end

    context "when the length and maxlength are specified" do
      it "should raise ArgumentError" do
        expect { described_class.digits maxlength: 5, length: 5 }.to raise_error(ArgumentError, /absolute length/)
      end
    end
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

  describe 'number' do
    subject(:grammar) { described_class.number }

    it { should match('0').and_interpret_as 'dtmf-0' }
    it { should match('123').and_interpret_as 'dtmf-1 dtmf-2 dtmf-3' }
    it { should match('1*01').and_interpret_as dtmf_seq %w(1 star 0 1) }
    it { should match('01*00').and_interpret_as dtmf_seq %w(0 1 star 0 0) }
    it do
      should match('100000000000*00')
        .and_interpret_as dtmf_seq %w(1 0 0 0 0 0 0 0 0 0 0 0 star 0 0)
    end
    it { should match('0*08').and_interpret_as dtmf_seq %w(0 star 0 8) }
    it { should match('*59').and_interpret_as 'dtmf-star dtmf-5 dtmf-9' }
    it { should match('0*0').and_interpret_as 'dtmf-0 dtmf-star dtmf-0' }
    it { should match('10*5').and_interpret_as dtmf_seq %w(1 0 star 5) }
    it { should match('123*').and_interpret_as dtmf_seq %w(1 2 3 star) }
    it do
      should match('123*2342').and_interpret_as dtmf_seq %w(1 2 3 star 2 3 4 2)
    end

    it { should potentially_match '*' }

    it { should not_match '#' }
    it { should not_match '**' }
    it { should not_match '0123*456*789' }
  end

  describe "phone" do
    subject(:grammar) { described_class.phone }

    it { should match('0').and_interpret_as('dtmf-0') }
    it { should match('0123').and_interpret_as('dtmf-0 dtmf-1 dtmf-2 dtmf-3') }
    it { should match('0123*456').and_interpret_as('dtmf-0 dtmf-1 dtmf-2 dtmf-3 dtmf-star dtmf-4 dtmf-5 dtmf-6') }

    it { should potentially_match('') }

    it { should not_match('#') }
    it { should not_match('0123*456*789') }
  end

  describe "time" do
    subject(:grammar) { described_class.time }

    it { should max_match('1235').and_interpret_as('dtmf-1 dtmf-2 dtmf-3 dtmf-5') }

    it { should match('12').and_interpret_as('dtmf-1 dtmf-2') }
    it { should match('4').and_interpret_as('dtmf-4') }
    it { should match('123').and_interpret_as('dtmf-1 dtmf-2 dtmf-3') }

    it { should not_match('*') }
    it { should not_match('#') }
  end
end
