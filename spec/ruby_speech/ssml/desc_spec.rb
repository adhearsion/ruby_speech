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
        Element.class_from_registration(:desc).should == Desc
      end

      describe "from a document" do
        let(:document) { '<desc xml:lang="en"/>' }

        subject { Element.import document }

        it { should be_instance_of Desc }

        its(:language) { should == 'en' }
      end

      describe "comparing objects" do
        it "should be equal if the content and language are the same" do
          Desc.new(doc, :language => 'jp', :content => "Hello there").should == Desc.new(doc, :language => 'jp', :content => "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Desc.new(doc, :content => "Hello").should_not == Desc.new(doc, :content => "Hello there")
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            Desc.new(doc, :language => 'jp').should_not == Desc.new(doc, :language => 'en')
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << Voice.new(doc) }.should raise_error(InvalidChildError, "A Desc can only accept Strings as children")
        end
      end
    end # Desc
  end # SSML
end # RubySpeech
