require 'spec_helper'

module RubySpeech
  module SSML
    describe Phoneme do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'phoneme' }

      describe "setting options in initializers" do
        subject { Phoneme.new doc, :alphabet => 'foo', :ph => 'bar' }

        its(:alphabet) { should == 'foo' }
        its(:ph)       { should == 'bar' }
      end

      it 'registers itself' do
        expect(Element.class_from_registration(:phoneme)).to eq(Phoneme)
      end

      describe "from a document" do
        let(:document) { '<phoneme alphabet="foo" ph="bar"/>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Phoneme }

        its(:alphabet) { should == 'foo' }
        its(:ph)       { should == 'bar' }
      end

      describe "comparing objects" do
        it "should be equal if the content, ph and alphabet are the same" do
          expect(Phoneme.new(doc, :alphabet => 'jp', :ph => 'foo', :content => "Hello there")).to eq(Phoneme.new(doc, :alphabet => 'jp', :ph => 'foo', :content => "Hello there"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Phoneme.new(doc, :content => "Hello")).not_to eq(Phoneme.new(doc, :content => "Hello there"))
          end
        end

        describe "when the ph is different" do
          it "should not be equal" do
            expect(Phoneme.new(doc, :ph => 'jp')).not_to eq(Phoneme.new(doc, :ph => 'en'))
          end
        end

        describe "when the alphabet is different" do
          it "should not be equal" do
            expect(Phoneme.new(doc, :alphabet => 'jp')).not_to eq(Phoneme.new(doc, :alphabet => 'en'))
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          expect { subject << 'anything' }.not_to raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          expect { subject << Voice.new(doc) }.to raise_error(InvalidChildError, "A Phoneme can only accept Strings as children")
        end
      end
    end # Desc
  end # SSML
end # RubySpeech
