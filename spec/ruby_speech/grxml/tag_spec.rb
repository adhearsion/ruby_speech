require 'spec_helper'

module RubySpeech
  module GRXML
    describe Tag do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'tag' }

      it 'registers itself' do
        expect(Element.class_from_registration(:tag)).to eq(Tag)
      end

      describe "from a document" do
        let(:document) { '<tag>hello</tag>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Tag }

        its(:content) { should == 'hello' }
      end

      describe "comparing objects" do
        it "should be equal if the content is the same" do
          expect(Tag.new(doc, :content => "hello")).to eq(Tag.new(doc, :content => "hello"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Tag.new(doc, :content => "Hello")).not_to eq(Tag.new(doc, :content => "Hello there"))
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          expect { subject << 'anything' }.not_to raise_error
        end
      end
    end # Tag
  end # GRXML
end # RubySpeech
