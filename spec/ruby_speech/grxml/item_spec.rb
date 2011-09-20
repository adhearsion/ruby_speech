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

        subject { Element.import parse_xml(document).root }

        it { should be_instance_of Item }

        its(:weight)  { should == 1.1 }
        its(:repeat)  { should == '1' }
        its(:content) { should == 'one' }
      end

      # TODO: validate various values for weight
      describe "#weight" do
        context "from a document" do
          describe "using .1" do 
            let(:document) { '<item weight=".1" repeat="1">one</item>' }
            subject { Element.import parse_xml(document).root }
            its(:weight)  { should == 0.1 }
          end
          describe "using 1." do 
            let(:document) { '<item weight="1." repeat="1">one</item>' }
            subject { Element.import parse_xml(document).root }
            its(:weight)  { should == 1.0 }
          end
          describe "using 1" do 
            let(:document) { '<item weight="1" repeat="1">one</item>' }
            subject { Element.import parse_xml(document).root }
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
            lambda { subject.weight = '.1'.to_f }.should_not raise_error
          end
          it "with an invalid value" do
            lambda { subject.weight = :one }.should raise_error(ArgumentError, "A Item's weight attribute must be a positive floating point number")
          end
        end
      end

      # TODO: validate various values for repeat
      #       http://www.w3.org/TR/speech-grammar/#S2.5
      describe "#repeat" do
        it "should allow 0 or more times"
        it "should allow 1 or more times"
        it "should allow range of times"
      end

      # TODO: handle repeat probability
      #       http://www.w3.org/TR/speech-grammar/#S2.5.1
      describe "#repeat-prob" do
        context "handle values if repeat is specified" do
          it "with a valid value"
          it "with and invalid value"
        end

        it "should be ignored if no repeat attribute is specified"
      end

      describe "#language" do
        before { subject.language = 'jp' }

        its(:language) { should == 'jp' }
      end
    end # Item
  end # GRXML
end # RubySpeech
