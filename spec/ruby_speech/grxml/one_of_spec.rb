require 'spec_helper'

module RubySpeech
  module GRXML
    describe OneOf do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'one-of' }

      it 'registers itself' do
        expect(Element.class_from_registration(:'one-of')).to eq(OneOf)
      end

      describe "from a document" do
        let(:document) { '<one-of> <item>test</item> </one-of>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of OneOf }
      end

      describe "#language" do
        before { subject.language = 'fr-CA' }

        its(:language) { should == 'fr-CA' }
      end

      describe "<<" do
        it "should accept Item" do
          expect { subject << Item.new(doc) }.not_to raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          expect { subject << 1 }.to raise_error(InvalidChildError, "A OneOf can only accept Item as children")
        end
      end

      describe "comparing objects" do
        it "should be equal if the language (when specified) is the same" do
          expect(OneOf.new(doc, :language => "jp")).to eq(OneOf.new(doc, :language => "jp"))
        end

        describe "when the language is different" do
          it "should not be equal" do
            expect(OneOf.new(doc, :language => "jp")).not_to eq(OneOf.new(doc, :content => "fr-CA"))
          end
        end
      end
    end # OneOf
  end # GRXML
end # RubySpeech
