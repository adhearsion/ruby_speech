require 'spec_helper'

module RubySpeech
  module GRXML
    describe OneOf do
      its(:name) { should == 'one-of' }

      it 'registers itself' do
        Element.class_from_registration(:'one-of').should == OneOf
      end

      describe "from a document" do
        let(:document) { '<one-of> <item>test</item> </one-of>' }

        subject { Element.import document }

        it { should be_instance_of OneOf }
      end

      describe "#language" do
        before { subject.language = 'fr-CA' }

        its(:language) { should == 'fr-CA' }
      end

      describe "<<" do
        it "should accept Item" do
          lambda { subject << Item.new }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << 1 }.should raise_error(InvalidChildError, "A OneOf can only accept Item as children")
        end
      end

      describe "comparing objects" do
        it "should be equal if the language (when specified) is the same" do
          OneOf.new(:language => "jp").should == OneOf.new(:language => "jp")
        end

        describe "when the language is different" do
          it "should not be equal" do
            OneOf.new(:language => "jp").should_not == OneOf.new(:content => "fr-CA")
          end
        end
      end
    end # OneOf
  end # GRXML
end # RubySpeech
