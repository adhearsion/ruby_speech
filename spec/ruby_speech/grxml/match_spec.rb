require 'spec_helper'

module RubySpeech
  module GRXML
    describe Match do
      subject do
        Match.new :mode           => :dtmf,
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
          Match.new(:mode => :dtmf, :confidence => 1, :utterance => '6', :interpretation => 'foo').should == Match.new(:mode => :dtmf, :confidence => 1, :utterance => '6', :interpretation => 'foo')
        end

        describe "when the mode is different" do
          it "should not be equal" do
            Match.new(:mode => :dtmf).should_not == Match.new(:mode => :speech)
          end
        end

        describe "when the confidence is different" do
          it "should not be equal" do
            Match.new(:confidence => 1).should_not == Match.new(:confidence => 0)
          end
        end

        describe "when the utterance is different" do
          it "should not be equal" do
            Match.new(:utterance => '6').should_not == Match.new(:utterance => 'foo')
          end
        end

        describe "when the interpretation is different" do
          it "should not be equal" do
            Match.new(:interpretation => 'foo').should_not == Match.new(:interpretation => 'bar')
          end
        end
      end
    end
  end
end
