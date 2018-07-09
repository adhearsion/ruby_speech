require 'spec_helper'

module RubySpeech
  module GRXML
    describe Item do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { Item.new doc, :weight => 1.1, :repeat => '1' }

      its(:name) { should == 'item' }

      its(:weight)  { should == 1.1 }
      its(:repeat)  { should == 1 }

      it 'registers itself' do
        expect(Element.class_from_registration(:item)).to eq(Item)
      end

      describe "everything from a document" do
        let(:document) { '<item weight="1.1" repeat="1">one</item>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Item }

        its(:weight)  { should == 1.1 }
        its(:repeat)  { should == 1 }
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
            expect { subject.weight = 1 }.not_to raise_error
            expect { subject.weight = 1.0 }.not_to raise_error
            expect { subject.weight = 0.1 }.not_to raise_error
            expect { subject.weight = '.1' }.not_to raise_error
            expect { subject.weight = '1.' }.not_to raise_error
          end

          it "with an invalid value" do
            expect { subject.weight = 'one' }.to raise_error(ArgumentError, "A Item's weight attribute must be a positive floating point number")
            expect { subject.weight = -1 }.to raise_error(ArgumentError, "A Item's weight attribute must be a positive floating point number")
          end
        end
      end

      # Validate various values for repeat -- http://www.w3.org/TR/speech-grammar/#S2.5
      describe "#repeat" do
        context "exact" do
          context "0" do
            before { subject.repeat = 0 }
            its(:repeat) { should == 0 }
          end

          context "5" do
            before { subject.repeat = 5 }
            its(:repeat) { should == 5 }
          end

          context "'1'" do
            before { subject.repeat = '1' }
            its(:repeat) { should == 1 }
          end

          it "invalid values" do
            expect { subject.repeat = -1 }.to raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            expect { subject.repeat = 'one' }.to raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
          end
        end

        context "ranges" do
          context "valid ranges from m to n" do
            context "'1-5'" do
              before { subject.repeat = '1-5' }
              its(:repeat) { should == (1..5) }
            end

            context "'0-5'" do
              before { subject.repeat = '0-5' }
              its(:repeat) { should == (0..5) }
            end

            context "0..5" do
              before { subject.repeat = 0..5 }
              its(:repeat) { should == (0..5) }
            end
          end

          it "illegal ranges from m to n" do
            expect { subject.repeat = '5-1' }.to raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            expect { subject.repeat = '-1-2' }.to raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            expect { subject.repeat = '1-2-3' }.to raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            expect { subject.repeat = '1-B' }.to raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            expect { subject.repeat = -1..2 }.to raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            expect { subject.repeat = 1..-2 }.to raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
          end

          context "valid ranges of m or more" do
            context "'3-'" do
              before { subject.repeat = '3-' }
              its(:repeat) { should == (3..Item::Inf) }
              its(:repeat) { should include 10000 }
            end

            context "'0-'" do
              before { subject.repeat = '0-' }
              its(:repeat) { should == (0..Item::Inf) }
              its(:repeat) { should include 10000 }
            end
          end

          it "illegal ranges for m or more" do
            expect { subject.repeat = '-1-' }.to raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            expect { subject.repeat = 'B-' }.to raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
          end
        end
      end

      # repeat probability (repeat-prob) -- http://www.w3.org/TR/speech-grammar/#S2.5.1
      describe "#repeat_prob" do
        it "should handle all valid values" do
          expect { subject.repeat_prob = 0 }.not_to raise_error
          expect { subject.repeat_prob = 1 }.not_to raise_error
          expect { subject.repeat_prob = 1.0 }.not_to raise_error
          expect { subject.repeat_prob = '1.' }.not_to raise_error
          expect { subject.repeat_prob = '1.0' }.not_to raise_error
          expect { subject.repeat_prob = '.5' }.not_to raise_error
        end

        it "should raise an error for invalid values" do
          expect { subject.repeat_prob = -1 }.to raise_error(ArgumentError, "A Item's repeat probablity attribute must be a floating point number between 0.0 and 1.0")
          expect { subject.repeat_prob = 1.5 }.to raise_error(ArgumentError, "A Item's repeat probablity attribute must be a floating point number between 0.0 and 1.0")
        end
      end

      describe "#language" do
        before { subject.language = 'jp' }

        its(:language) { should == 'jp' }
      end


      describe "<<" do
        it "should accept String" do
          expect { subject << 'anything' }.not_to raise_error
        end

        it "should accept OneOf" do
          expect { subject << OneOf.new(doc) }.not_to raise_error
        end

        it "should accept Item" do
          expect { subject << Item.new(doc) }.not_to raise_error
        end

        it "should accept Ruleref" do
          expect { subject << Ruleref.new(doc) }.not_to raise_error
        end

        it "should accept Tag" do
          expect { subject << Tag.new(doc) }.not_to raise_error
        end

        it "should accept Token" do
          expect { subject << Token.new(doc) }.not_to raise_error
        end
      end
    end # Item
  end # GRXML
end # RubySpeech
