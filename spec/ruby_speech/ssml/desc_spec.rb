require 'spec_helper'

module RubySpeech
  module SSML
    describe Desc do
      its(:name) { should == 'desc' }

      describe "setting options in initializers" do
        subject { Desc.new :language => 'foo' }

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
          Desc.new(:language => 'jp', :content => "Hello there").should == Desc.new(:language => 'jp', :content => "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Desc.new(:content => "Hello").should_not == Desc.new(:content => "Hello there")
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            Desc.new(:language => 'jp').should_not == Desc.new(:language => 'en')
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << Voice.new }.should raise_error(InvalidChildError, "A Desc can only accept Strings as children")
        end
      end
    end # Desc
  end # SSML
end # RubySpeech
