require 'spec_helper'

module RubySpeech
  module GRXML
    describe NoMatch do
      describe "equality" do
        it "should be equal to another NoMatch" do
          expect(NoMatch.new).to eq(NoMatch.new)
        end

        it "should not equal a match" do
          expect(NoMatch.new).not_to eq(Match.new)
        end
      end
    end
  end
end
