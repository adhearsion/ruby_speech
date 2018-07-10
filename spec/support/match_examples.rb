shared_examples_for "match" do
  subject do
    described_class.new :mode => :dtmf,
              :confidence     => 1,
              :utterance      => '6',
              :interpretation => 'foo'
  end

  its(:mode)            { should == :dtmf }
  its(:confidence)      { should == 1 }
  its(:utterance)       { should == '6' }
  its(:interpretation)  { should == 'foo' }

  describe "equality" do
    it "should be equal when mode, confidence, utterance and interpretation are the same" do
      expect(described_class.new(:mode => :dtmf, :confidence => 1, :utterance => '6', :interpretation => 'foo')).to eq(described_class.new(:mode => :dtmf, :confidence => 1, :utterance => '6', :interpretation => 'foo'))
    end

    describe "when the mode is different" do
      it "should not be equal" do
        expect(described_class.new(:mode => :dtmf)).not_to eq(described_class.new(:mode => :speech))
      end
    end

    describe "when the confidence is different" do
      it "should not be equal" do
        expect(described_class.new(:confidence => 1)).not_to eq(described_class.new(:confidence => 0))
      end
    end

    describe "when the utterance is different" do
      it "should not be equal" do
        expect(described_class.new(:utterance => '6')).not_to eq(described_class.new(:utterance => 'foo'))
      end
    end

    describe "when the interpretation is different" do
      it "should not be equal" do
        expect(described_class.new(:interpretation => 'foo')).not_to eq(described_class.new(:interpretation => 'bar'))
      end
    end
  end
end
