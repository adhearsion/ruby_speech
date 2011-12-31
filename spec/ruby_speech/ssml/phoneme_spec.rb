require 'spec_helper'

module RubySpeech
  module SSML
    describe Phoneme do
      its(:name) { should == 'phoneme' }

      describe "setting options in initializers" do
        subject { Phoneme.new :alphabet => 'foo', :ph => 'bar' }

        its(:alphabet) { should == 'foo' }
        its(:ph)       { should == 'bar' }
      end

      it 'registers itself' do
        Element.class_from_registration(:phoneme).should == Phoneme
      end

      describe "from a document" do
        let(:document) { '<phoneme alphabet="foo" ph="bar"/>' }

        subject { Element.import document }

        it { should be_instance_of Phoneme }

        its(:alphabet) { should == 'foo' }
        its(:ph)       { should == 'bar' }
      end

      describe "comparing objects" do
        it "should be equal if the content, ph and alphabet are the same" do
          Phoneme.new(:alphabet => 'jp', :ph => 'foo', :content => "Hello there").should == Phoneme.new(:alphabet => 'jp', :ph => 'foo', :content => "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Phoneme.new(:content => "Hello").should_not == Phoneme.new(:content => "Hello there")
          end
        end

        describe "when the ph is different" do
          it "should not be equal" do
            Phoneme.new(:ph => 'jp').should_not == Phoneme.new(:ph => 'en')
          end
        end

        describe "when the alphabet is different" do
          it "should not be equal" do
            Phoneme.new(:alphabet => 'jp').should_not == Phoneme.new(:alphabet => 'en')
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << Voice.new }.should raise_error(InvalidChildError, "A Phoneme can only accept Strings as children")
        end
      end
    end # Desc
  end # SSML
end # RubySpeech
