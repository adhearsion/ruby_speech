require 'spec_helper'

module RubySpeech
  module GRXML
    describe Token do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'token' }

      it 'registers itself' do
        expect(Element.class_from_registration(:token)).to eq(Token)
      end

      describe "from a document" do
        let(:document) { '<token>hello</token>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Token }

        its(:content) { should == 'hello' }
      end

      describe "#language" do
        before { subject.language = 'jp' }

        its(:language) { should == 'jp' }
      end

      describe "#normalize_whitespace" do
        it "should remove leading & trailing whitespace and collapse multiple spaces down to 1" do
          element = Element.import '<token> Welcome to  San Francisco </token>'

          element.normalize_whitespace

          expect(element.content).to eq('Welcome to San Francisco')
        end
      end

      describe "comparing objects" do
        it "should be equal if the content is the same" do
          expect(Token.new(doc, :content => "hello")).to eq(Token.new(doc, :content => "hello"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Token.new(doc, :content => "Hello")).not_to eq(Token.new(doc, :content => "Hello there"))
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          expect { subject << 'anything' }.not_to raise_error
        end

        it "should allow chaining" do
          subject << 'foo' << 'bar'
          expect(subject.content).to eq('foobar')
        end
      end
    end # Token
  end # GRXML
end # RubySpeech
