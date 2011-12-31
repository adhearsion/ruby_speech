require 'spec_helper'

module RubySpeech
  module SSML
    describe S do
      its(:name) { should == 's' }

      describe "setting options in initializers" do
        subject { S.new :language => 'jp' }

        its(:language) { should == 'jp' }
      end

      it 'registers itself' do
        Element.class_from_registration(:s).should == S
      end

      describe "from a document" do
        let(:document) { '<s>foo</s>' }

        subject { S.import document }

        it { should be_instance_of S }
        its(:content) { should == 'foo' }
      end

      describe "comparing objects" do
        it "should be equal if the content and language are the same" do
          S.new(:language => 'jp', :content => "Hello there").should == S.new(:language => 'jp', :content => "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            S.new(:content => "Hello").should_not == S.new(:content => "Hello there")
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            S.new(:language => 'jp').should_not == S.new(:language => 'en')
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should accept Audio" do
          lambda { subject << Audio.new }.should_not raise_error
        end

        it "should accept Break" do
          lambda { subject << Break.new }.should_not raise_error
        end

        it "should accept Emphasis" do
          lambda { subject << Emphasis.new }.should_not raise_error
        end

        it "should accept Mark" do
          pending
          lambda { subject << Mark.new }.should_not raise_error
        end

        it "should accept Phoneme" do
          pending
          lambda { subject << Phoneme.new }.should_not raise_error
        end

        it "should accept Prosody" do
          lambda { subject << Prosody.new }.should_not raise_error
        end

        it "should accept SayAs" do
          lambda { subject << SayAs.new(:interpret_as => :foo) }.should_not raise_error
        end

        it "should accept Sub" do
          pending
          lambda { subject << Sub.new }.should_not raise_error
        end

        it "should accept Voice" do
          lambda { subject << Voice.new }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << 1 }.should raise_error(InvalidChildError, "An S can only accept String, Audio, Break, Emphasis, Mark, Phoneme, Prosody, SayAs, Sub, Voice as children")
        end
      end
    end # S
  end # SSML
end # RubySpeech
