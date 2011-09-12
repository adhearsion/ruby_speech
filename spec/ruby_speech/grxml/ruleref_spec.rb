require 'spec_helper'

module RubySpeech
  module GRXML
    describe Ruleref do
      subject { Ruleref.new :uri => '#testrule' }

      its(:name)  { should == 'ruleref' }

      its(:uri)   { should == '#testrule' }

      it 'registers itself' do
        Element.class_from_registration(:ruleref).should == Ruleref
      end

      describe "from a document" do
        let(:document) { '<ruleref uri="#one" />' }

        subject { Element.import parse_xml(document).root }

        it { should be_instance_of Ruleref }

        its(:uri) { should == '#one' }
      end

      #describe "special" do
        # TODO: specify the valid values for the special attribute
      #end

      # TODO: check that only special or uri are specified

    end # Ruleref
  end # GRXML
end # RubySpeech
