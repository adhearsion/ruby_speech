require 'spec_helper'

module RubySpeech
  module SSML
    describe Mark do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:node_name) { should == 'mark' }

      describe "setting options in initializers" do
        subject { Mark.new doc, :name => 'foo' }

        its(:name)  { should == 'foo' }
      end

      it 'registers itself' do
        Element.class_from_registration(:mark).should == Mark
      end

      describe "from a document" do
        let(:document) { '<mark name="foo"/>' }

        subject { Element.import document }

        it { should be_instance_of Mark }

        its(:name)  { should == 'foo' }
      end

      describe "#name" do
        before { subject.name = 'foo' }

        its(:name) { should == 'foo' }
      end

      describe "<<" do
        it "should always raise InvalidChildError" do
          lambda { subject << 'anything' }.should raise_error(InvalidChildError, "A Mark cannot contain children")
        end
      end

      describe "comparing objects" do
        it "should be equal if the name is the same" do
          Mark.new(doc, :name => "foo").should == Mark.new(doc, :name => "foo")
        end

        describe "when the name is different" do
          it "should not be equal" do
            Mark.new(doc, :name => "foo").should_not == Mark.new(doc, :name => "bar")
          end
        end
      end
    end # Mark
  end # SSML
end # RubySpeech
