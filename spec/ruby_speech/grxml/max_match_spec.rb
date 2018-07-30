require 'spec_helper'

module RubySpeech
  module GRXML
    describe MaxMatch do
      it_behaves_like "match"

      it { is_expected.to be_a Match }

      describe "equality" do
        it "should never be equal to a MaxMatch" do
          expect(described_class.new).not_to eql(Match.new)
        end
      end
    end
  end
end
