require 'spec_helper'

module RubySpeech
  module SSML
    describe P do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'p' }

      describe "setting options in initializers" do
        subject { P.new doc, :language => 'jp' }

        its(:language) { should == 'jp' }
      end

      it 'registers itself' do
        Element.class_from_registration(:p).should == P
      end

      describe "from a document" do
        let(:document) { '<p>foo</p>' }

        subject { Element.import document }

        it { should be_instance_of P }
        its(:content) { should == 'foo' }
      end

      describe "comparing objects" do
        it "should be equal if the content and language are the same" do
          P.new(doc, :language => 'jp', :content => "Hello there").should == P.new(doc, :language => 'jp', :content => "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            P.new(doc, :content => "Hello").should_not == P.new(doc, :content => "Hello there")
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            P.new(doc, :language => 'jp').should_not == P.new(doc, :language => 'en')
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should accept Audio" do
          lambda { subject << Audio.new(doc) }.should_not raise_error
        end

        it "should accept Break" do
          lambda { subject << Break.new(doc) }.should_not raise_error
        end

        it "should accept Emphasis" do
          lambda { subject << Emphasis.new(doc) }.should_not raise_error
        end

        it "should accept Mark" do
          lambda { subject << Mark.new(doc) }.should_not raise_error
        end

        it "should accept Phoneme" do
          lambda { subject << Phoneme.new(doc) }.should_not raise_error
        end

        it "should accept Prosody" do
          lambda { subject << Prosody.new(doc) }.should_not raise_error
        end

        it "should accept SayAs" do
          lambda { subject << SayAs.new(doc, :interpret_as => :foo) }.should_not raise_error
        end

        it "should accept Sub" do
          lambda { subject << Sub.new(doc) }.should_not raise_error
        end

        it "should accept S" do
          lambda { subject << S.new(doc) }.should_not raise_error
        end

        it "should accept Voice" do
          lambda { subject << Voice.new(doc) }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << 1 }.should raise_error(InvalidChildError, "A P can only accept String, Audio, Break, Emphasis, Mark, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
        end
      end
    end # P
  end # SSML
end # RubySpeech
