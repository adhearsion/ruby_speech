require 'spec_helper'

module RubySpeech
  module GRXML
    describe Item do
      subject { Item.new :weight => 1.1, :repeat => '1' }

      its(:name) { should == 'item' }

      its(:weight)  { should == 1.1 }
      its(:repeat)  { should == 1 }

      it 'registers itself' do
        Element.class_from_registration(:item).should == Item
      end

      describe "everything from a document" do
        let(:document) { '<item weight="1.1" repeat="1">one</item>' }

        subject { Element.import document }

        it { should be_instance_of Item }

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
            lambda { subject.repeat = -1 }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = 'one' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
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
            lambda { subject.repeat = '5-1' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = '-1-2' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = '1-2-3' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = '1-B' }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = -1..2 }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
            lambda { subject.repeat = 1..-2 }.should raise_error(ArgumentError, "A Item's repeat must be 0 or a positive integer")
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

      describe "#potential_match?" do
        subject { Item.new }

        before do
          tokens.each { |token| subject << token }
          subject.repeat = repeat if repeat
        end

        context "with a single token of '6'" do
          let(:tokens) { [Token.new << '6'] }

          context "with no repeat" do
            let(:repeat) { nil }

            it "should be true for '6'" do
              subject.potential_match?('6').should be true
            end

            %w{5 55 65 66}.each do |input|
              it "should be false for '#{input}'" do
                subject.potential_match?(input).should be false
              end
            end
          end

          context "with an absolute repeat of 3" do
            let(:repeat) { 3 }

            %w{6 66 666}.each do |input|
              it "should be true for '#{input}'" do
                subject.potential_match?(input).should be true
              end
            end

            %w{5 55 65 6666}.each do |input|
              it "should be false for '#{input}'" do
                subject.potential_match?(input).should be false
              end
            end
          end

          context "with a range repeat of 0..2" do
            let(:repeat) { 0..2 }

            it "should be true for ''" do
              subject.potential_match?('').should be true
            end

            %w{6 66}.each do |input|
              it "should be true for '#{input}'" do
                subject.potential_match?(input).should be true
              end
            end

            %w{5 55 65 666}.each do |input|
              it "should be false for '#{input}'" do
                subject.potential_match?(input).should be false
              end
            end
          end

          context "with a minimum repeat of 2" do
            let(:repeat) { 2..Item::Inf }

            %w{6 66 666 6666 66666}.each do |input|
              it "should be true for '#{input}'" do
                subject.potential_match?(input).should be true
              end
            end

            %w{5 55 65}.each do |input|
              it "should be false for '#{input}'" do
                subject.potential_match?(input).should be false
              end
            end
          end
        end

        context "with a collection of two tokens of '6' and '7'" do
          let(:tokens) { [Token.new << '6', Token.new << '7'] }

          context "with no repeat" do
            let(:repeat) { nil }

            %w{6 67}.each do |input|
              it "should be true for '#{input}'" do
                subject.potential_match?(input).should be true
              end
            end

            %w{5 55 65 66 676}.each do |input|
              it "should be false for '#{input}'" do
                subject.potential_match?(input).should be false
              end
            end
          end

          context "with an absolute repeat of 3" do
            let(:repeat) { 3 }

            %w{6 67 676 6767 67676 676767}.each do |input|
              it "should be true for '#{input}'" do
                subject.potential_match?(input).should be true
              end
            end

            %w{5 57 66 677 5767 67677 676766 6767676}.each do |input|
              it "should be false for '#{input}'" do
                subject.potential_match?(input).should be false
              end
            end
          end

          context "with a range repeat of 0..2" do
            let(:repeat) { 0..2 }

            it "should be true for ''" do
              subject.potential_match?('').should be true
            end

            %w{6 67 676 6767}.each do |input|
              it "should be true for '#{input}'" do
                subject.potential_match?(input).should be true
              end
            end

            %w{5 57 66 677 5767 67676 67677 676766 6767676}.each do |input|
              it "should be false for '#{input}'" do
                subject.potential_match?(input).should be false
              end
            end
          end

          context "with a minimum repeat of 2" do
            let(:repeat) { 2..Item::Inf }

            %w{6 67 676 6767 67676 676767 67676767}.each do |input|
              it "should be true for '#{input}'" do
                subject.potential_match?(input).should be true
              end
            end

            %w{5 57 66 677 5767 67677 676766}.each do |input|
              it "should be false for '#{input}'" do
                subject.potential_match?(input).should be false
              end
            end
          end
        end
      end
    end # Item
  end # GRXML
end # RubySpeech
