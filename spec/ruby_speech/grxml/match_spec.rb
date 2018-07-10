require 'spec_helper'

module RubySpeech
  module GRXML
    describe Match do
      it_behaves_like "match"

      describe "equality" do
        it "should never be equal to a MaxMatch" do
          expect(described_class.new).not_to eql(MaxMatch.new)
        end
      end
    end
  end
end
