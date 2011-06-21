require 'spec_helper'

module RubySpeech
  module SSML
    describe Speak do
      it { should be_a_valid_ssml_document }

      its(:name) { should == 'speak' }
      its(:language) { should == 'en-US' }

      describe "#language" do
        before { subject.language = 'jp' }

        its(:language) { should == 'jp' }
      end

      describe "#base_uri" do
        before { subject.base_uri = 'blah' }

        its(:base_uri) { should == 'blah' }
      end
    end # Speak
  end # SSML
end # RubySpeech
