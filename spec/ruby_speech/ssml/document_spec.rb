require 'spec_helper'

module RubySpeech
  module SSML
    describe Document do
      it { should be_a Nokogiri::XML::Document}
    end # Break
  end # SSML
end # RubySpeech
