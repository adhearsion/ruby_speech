require 'spec_helper'

module RubySpeech
  module SSML
    describe Break do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'break' }

      describe "setting options in initializers" do
        subject { Break.new doc, :strength => :strong, :time => 3.seconds }

        its(:strength)  { should == :strong }
        its(:time)      { should == 3.seconds }
      end

      it 'registers itself' do
        Element.class_from_registration(:break).should == Break
      end

      describe "from a document" do
        let(:document) { '<break strength="strong" time="3"/>' }

        subject { Element.import document }

        it { should be_instance_of Break }

        its(:strength)  { should == :strong }
        its(:time)      { should == 3.seconds }
      end

      describe "#strength" do
        before { subject.strength = :strong }

        its(:strength) { should == :strong }

        it "with a valid level" do
          lambda { subject.strength = :none }.should_not raise_error
          lambda { subject.strength = :'x-weak' }.should_not raise_error
          lambda { subject.strength = :weak }.should_not raise_error
          lambda { subject.strength = :medium }.should_not raise_error
          lambda { subject.strength = :strong }.should_not raise_error
          lambda { subject.strength = :'x-strong' }.should_not raise_error
        end

        it "with an invalid strength" do
          lambda { subject.strength = :something }.should raise_error(ArgumentError, "You must specify a valid strength (:none, :\"x-weak\", :weak, :medium, :strong, :\"x-strong\")")
        end
      end

      describe "#time" do
        context "with a valid value" do
          before { subject.time = 3.seconds }

          its(:time) { should == 3.seconds }
        end

        context "with a negative value" do
          it do
            lambda { subject.time = -3.seconds }.should raise_error(ArgumentError, "You must specify a valid time (positive float value in seconds)")
          end
        end

        context "with an invalid value" do
          it do
            lambda { subject.time = 'blah' }.should raise_error(ArgumentError, "You must specify a valid time (positive float value in seconds)")
          end
        end
      end

      describe "<<" do
        it "should always raise InvalidChildError" do
          lambda { subject << 'anything' }.should raise_error(InvalidChildError, "A Break cannot contain children")
        end
      end

      describe "comparing objects" do
        it "should be equal if the content, strength and base uri are the same" do
          Break.new(doc, :strength => :strong, :time => 1.second, :content => "Hello there").should == Break.new(doc, :strength => :strong, :time => 1.second, :content => "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Break.new(doc, :content => "Hello").should_not == Break.new(doc, :content => "Hello there")
          end
        end

        describe "when the strength is different" do
          it "should not be equal" do
            Break.new(doc, :strength => :strong).should_not == Break.new(doc, :strength => :weak)
          end
        end

        describe "when the time is different" do
          it "should not be equal" do
            Break.new(doc, :time => 1.second).should_not == Break.new(doc, :time => 2.seconds)
          end
        end
      end
    end # Break
  end # SSML
end # RubySpeech
