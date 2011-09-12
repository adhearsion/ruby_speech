require 'spec_helper'

module RubySpeech
  module GRXML
    describe Rule do
      subject { Rule.new :id => 'one', :scope => 'public' }

      its(:name) { should == 'rule' }

      its(:id)    { should == 'one' }
      its(:scope) { should == 'public' }

      it 'registers itself' do
        Element.class_from_registration(:rule).should == Rule
      end

      describe "from a document" do
        let(:document) { '<rule id="one" scope="public"> <item /> </rule>' }

        subject { Element.import parse_xml(document).root }

        it { should be_instance_of Rule }

        its(:id)    { should == 'one' }
        its(:scope) { should == 'public' }
      end

      describe "scope" do
        it "should accept public or private" do
          lambda { Rule.new :id => 'one', :scope => 'public' }.should_not raise_error
          lambda { Rule.new :id => 'one', :scope => 'private' }.should_not raise_error
        end

        it "should raise ArgumentError with any other scope" do
          lambda { Rule.new :id => 'one', :scope => 'invalid_scope' }.should raise_error(ArgumentError, "A Rule's scope can only be 'public' or 'private'")
        end
      end
    end # Rule
  end # GRXML
end # RubySpeech
