require 'spec_helper'

module RubySpeech
  module GRXML
    describe PotentialMatch do
      describe "equality" do
        it "should be equal to another PotentialMatch" do
          expect(PotentialMatch.new).to eq(PotentialMatch.new)
        end

        it "should not equal a match" do
          expect(PotentialMatch.new).not_to eq(Match.new)
        end
      end
    end
  end
end
