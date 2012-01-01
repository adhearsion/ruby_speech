require 'spec_helper'

module RubySpeech
  module GRXML
    describe NoMatch do
      describe "equality" do
        it "should be equal to another NoMatch" do
          NoMatch.new.should == NoMatch.new
        end

        it "should not equal a match" do
          NoMatch.new.should_not == Match.new
        end
      end
    end
  end
end
