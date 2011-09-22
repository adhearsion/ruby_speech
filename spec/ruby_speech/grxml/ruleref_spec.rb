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

      describe "#special" do
        subject { Ruleref.new }

        context "with reserved values" do
          it "with a valid value" do
            lambda { subject.special = :NULL }.should_not raise_error
            lambda { subject.special = :VOID }.should_not raise_error
            lambda { subject.special = 'GARBAGE' }.should_not raise_error
          end
          it "with an invalid value" do
            lambda { subject.special = :SOMETHINGELSE }.should raise_error
          end
        end
      end

      describe "#uri" do
        it "allows implict, explicit and external references" do
          lambda { subject.uri = '#dtmf' }.should_not raise_error
          lambda { subject.uri = '../test.grxml' }.should_not raise_error
          lambda { subject.uri = 'http://grammar.example.com/world-cities.grxml#canada' }.should_not raise_error
        end
      end

      describe "only uri or special can be specified" do
        it "should raise an error" do
          lambda { subject << Ruleref.new(:uri => '#test', :special => :NULL) }.should raise_error(ArgumentError, "A Ruleref can only take uri or special")
        end
      end
    end # Ruleref
  end # GRXML
end # RubySpeech
