require 'spec_helper'

module RubySpeech
  module GRXML
    describe PotentialMatch do
      describe "equality" do
        it "should be equal to another PotentialMatch" do
          PotentialMatch.new.should == PotentialMatch.new
        end

        it "should not equal a match" do
          PotentialMatch.new.should_not == Match.new
        end
      end
    end
  end
end
