require 'spec_helper'

module RubySpeech
  module SSML
    describe Emphasis do
      its(:name) { should == 'emphasis' }

      describe "setting options in initializers" do
        subject { Emphasis.new :level => :strong }

        its(:level) { should == :strong }
      end

      describe "#level" do
        before { subject.level = :strong }

        its(:level) { should == :strong }

        it "with a valid level" do
          lambda { subject.level = :strong }.should_not raise_error
          lambda { subject.level = :moderate }.should_not raise_error
          lambda { subject.level = :none }.should_not raise_error
          lambda { subject.level = :reduced }.should_not raise_error
        end

        it "with an invalid level" do
          lambda { subject.level = :something }.should raise_error(ArgumentError, "You must specify a valid level (:strong, :moderate, :none, :reduced)")
        end
      end

      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should accept Audio" do
          pending
          lambda { subject << Audio.new }.should_not raise_error
        end

        it "should accept Break" do
          lambda { subject << Break.new }.should_not raise_error
        end

        it "should accept Emphasis" do
          lambda { subject << Emphasis.new }.should_not raise_error
        end

        it "should accept Mark" do
          pending
          lambda { subject << Mark.new }.should_not raise_error
        end

        it "should accept Phoneme" do
          pending
          lambda { subject << Phoneme.new }.should_not raise_error
        end

        it "should accept Prosody" do
          lambda { subject << Prosody.new }.should_not raise_error
        end

        it "should accept SayAs" do
          pending
          lambda { subject << SayAs.new }.should_not raise_error
        end

        it "should accept Sub" do
          pending
          lambda { subject << Sub.new }.should_not raise_error
        end

        it "should accept Voice" do
          lambda { subject << Voice.new }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << 1 }.should raise_error(InvalidChildError, "An Emphasis can only accept String, Audio, Break, Emphasis, Mark, Phoneme, Prosody, SayAs, Sub, Voice as children")
        end
      end
    end # Emphasis
  end # SSML
end # RubySpeech
