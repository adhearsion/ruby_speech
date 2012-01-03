require 'spec_helper'

module RubySpeech
  module GRXML
    describe Item do
      subject { Item.new :weight => 1.1, :repeat => '1' }

      its(:name) { should == 'item' }

      its(:weight)  { should == 1.1 }
      its(:repeat)  { should == '1' }

      it 'registers itself' do
        Element.class_from_registration(:item).should == Item
      end

      describe "everything from a document" do
        let(:document) { '<item weight="1.1" repeat="1">one</item>' }

        subject { Element.import document }

        it { should be_instance_of Item }

        its(:weight)  { should == 1.1 }
        its(:repeat)  { should == '1' }
        its(:content) { should == 'one' }
      end

      describe "#weight" do
        context "from a document" do
          subject { Element.import document }

          describe "using .1" do
            let(:document) { '<item weight=".1" repeat="1">one</item>' }
            its(:weight)  { should == 0.1 }
          end

          describe "using 1." do
            let(:document) { '<item weight="1." repeat="1">one</item>' }
            its(:weight)  { should == 1.0 }
          end

          describe "using 1" do
            let(:document) { '<item weight="1" repeat="1">one</item>' }
            its(:weight)  { should == 1.0 }
          end
        end

        context "positive floating point numbers" do
          before { subject.weight = 1.1 }

          its(:weight) { should == 1.1 }

          it "with valid value" do
            lambda { subject.weight = 1 }.should_not raise_error
            lambda { subject.weight = 1.0 }.should_not raise_error
            lambda { subject.weight = 0.1 }.should_not raise_error
            lambda { subject.weight = '.1' }.should_not raise_error
            lambda { subject.weight = '1.' }.should_not raise_error
          end

          it "with an invalid value" do
            lambda { subject.weight = 'one' }.should raise_error(ArgumentError, "A Item's weight attribute must be a positive floating point number")
            lambda { subject.weight = -1 }.should raise_error(ArgumentError, "A Item's weight attribute must be a positive floating point number")
          end
        end
      end

      # Validate various values for repeat -- http://www.w3.org/TR/speech-grammar/#S2.5
      describe "#repeat" do
        context "exact" do
          it "valid values (0 or a positive integer)" do
            lambda { subject.repeat = 0 }.should_not raise_error
            lambda { subject.repeat = 5 }.should_not raise_error
            lambda { subject.repeat = '1' }.should_not raise_error
          end

          it "invalid values" do
            lambda { subject.repeat = -1 }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = 'one' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
          end
        end

        context "ranges" do
          it "valid ranges from m to n" do
            lambda { subject.repeat = '1-5' }.should_not raise_error
            lambda { subject.repeat = '0-5' }.should_not raise_error
            lambda { subject.repeat = 0..5 }.should_not raise_error
          end

          it "illegal ranges from m to n" do
            lambda { subject.repeat = '5-1' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = '-1-2' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = '1-2-3' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = '1-B' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = -1..2 }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = 1..-2 }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
          end

          it "valid ranges of m or more" do
            lambda { subject.repeat = '3-' }.should_not raise_error
            lambda { subject.repeat = '0-' }.should_not raise_error
          end

          it "illegal ranges for m or more" do
            lambda { subject.repeat = '-1-' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = 'B-' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
          end
        end
      end

      # repeat probability (repeat-prob) -- http://www.w3.org/TR/speech-grammar/#S2.5.1
      describe "#repeat_prob" do
        it "should handle all valid values" do
          lambda { subject.repeat_prob = 0 }.should_not raise_error
          lambda { subject.repeat_prob = 1 }.should_not raise_error
          lambda { subject.repeat_prob = 1.0 }.should_not raise_error
          lambda { subject.repeat_prob = '1.' }.should_not raise_error
          lambda { subject.repeat_prob = '1.0' }.should_not raise_error
          lambda { subject.repeat_prob = '.5' }.should_not raise_error
        end

        it "should raise an error for invalid values" do
          lambda { subject.repeat_prob = -1 }.should raise_error(ArgumentError, "A Item's repeat probablity attribute must be a floating point number between 0.0 and 1.0")
          lambda { subject.repeat_prob = 1.5 }.should raise_error(ArgumentError, "A Item's repeat probablity attribute must be a floating point number between 0.0 and 1.0")
        end
      end

      describe "#language" do
        before { subject.language = 'jp' }

        its(:language) { should == 'jp' }
      end


      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should accept OneOf" do
          lambda { subject << OneOf.new }.should_not raise_error
        end

        it "should accept Item" do
          lambda { subject << Item.new }.should_not raise_error
        end

        it "should accept Ruleref" do
          lambda { subject << Ruleref.new }.should_not raise_error
        end

        it "should accept Tag" do
          lambda { subject << Tag.new }.should_not raise_error
        end

        it "should accept Token" do
          lambda { subject << Token.new }.should_not raise_error
        end
      end
    end # Item
  end # GRXML
end # RubySpeech
