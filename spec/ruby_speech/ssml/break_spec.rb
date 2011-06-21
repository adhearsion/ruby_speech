require 'spec_helper'

module RubySpeech
  module SSML
    describe Break do
      its(:name) { should == 'break' }

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

      # TODO: The break element cannot take children
    end # Break
  end # SSML
end # RubySpeech
