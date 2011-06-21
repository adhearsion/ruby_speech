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

      # TODO: The emphasis element can only contain text to be rendered and the following elements: audio, break, emphasis, mark, phoneme, prosody, say-as, sub, voice.
    end # Emphasis
  end # SSML
end # RubySpeech
