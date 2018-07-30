require 'spec_helper'

module RubySpeech
  module SSML
    describe Desc do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'desc' }

      describe "setting options in initializers" do
        subject { Desc.new doc, :language => 'foo' }

        its(:language) { should == 'foo' }
      end

      it 'registers itself' do
        expect(Element.class_from_registration(:desc)).to eq(Desc)
      end

      describe "from a document" do
        let(:document) { '<desc xml:lang="en"/>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Desc }

        its(:language) { should == 'en' }
      end

      describe "comparing objects" do
        it "should be equal if the content and language are the same" do
          expect(Desc.new(doc, :language => 'jp', :content => "Hello there")).to eq(Desc.new(doc, :language => 'jp', :content => "Hello there"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Desc.new(doc, :content => "Hello")).not_to eq(Desc.new(doc, :content => "Hello there"))
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            expect(Desc.new(doc, :language => 'jp')).not_to eq(Desc.new(doc, :language => 'en'))
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          expect { subject << 'anything' }.not_to raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          expect { subject << Voice.new(doc) }.to raise_error(InvalidChildError, "A Desc can only accept Strings as children")
        end
      end
    end # Desc
  end # SSML
end # RubySpeech
