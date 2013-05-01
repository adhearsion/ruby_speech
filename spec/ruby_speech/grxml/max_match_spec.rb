require 'spec_helper'

module RubySpeech
  module GRXML
    describe MaxMatch do
      it_behaves_like "match"

      it { should be_a Match }

      describe "equality" do
        it "should never be equal to a MaxMatch" do
          described_class.new.should_not eql(Match.new)
        end
      end
    end
  end
end
