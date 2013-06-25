require 'spec_helper'

module RubySpeech
  module GRXML
    describe Token do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'token' }

      it 'registers itself' do
        Element.class_from_registration(:token).should == Token
      end

      describe "from a document" do
        let(:document) { '<token>hello</token>' }

        subject { Element.import document }

        it { should be_instance_of Token }

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

          element.content.should == 'Welcome to San Francisco'
        end
      end

      describe "comparing objects" do
        it "should be equal if the content is the same" do
          Token.new(doc, :content => "hello").should == Token.new(doc, :content => "hello")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Token.new(doc, :content => "Hello").should_not == Token.new(doc, :content => "Hello there")
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should allow chaining" do
          subject << 'foo' << 'bar'
          subject.content.should == 'foobar'
        end
      end
    end # Token
  end # GRXML
end # RubySpeech
