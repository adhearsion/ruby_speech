require 'spec_helper'

module RubySpeech
  module SSML
    describe Speak do
      it { should be_a_valid_ssml_document }

      its(:name) { should == 'speak' }
      its(:language) { should == 'en-US' }

      describe "setting options in initializers" do
        subject { Speak.new :language => 'jp', :base_uri => 'blah' }

        its(:language) { should == 'jp' }
        its(:base_uri) { should == 'blah' }
      end

      describe "#language" do
        before { subject.language = 'jp' }

        its(:language) { should == 'jp' }
      end

      describe "#base_uri" do
        before { subject.base_uri = 'blah' }

        its(:base_uri) { should == 'blah' }
      end

      describe "comparing objects" do
        it "should be equal if the content, language and base uri are the same" do
          Speak.new(language: 'en-GB', base_uri: 'blah', content: "Hello there").should == Speak.new(language: 'en-GB', base_uri: 'blah', content: "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Speak.new(content: "Hello").should_not == Speak.new(content: "Hello there")
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            Speak.new(language: 'en-US').should_not == Speak.new(language: 'en-GB')
          end
        end

        describe "when the base URI is different" do
          it "should not be equal" do
            Speak.new(base_uri: 'foo').should_not == Speak.new(base_uri: 'bar')
          end
        end
      end

      it "should allow creating child SSML elements" do
        s = Speak.new
        s.voice gender: :male, content: 'Hello'
        expected_s = Speak.new
        expected_s << Voice.new(gender: :male, content: 'Hello')
        s.should == expected_s
      end

      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should accept Audio" do
          pending
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

        it "should accept P" do
          pending
          lambda { subject << P.new }.should_not raise_error
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

        it "should accept S" do
          pending
          lambda { subject << S.new }.should_not raise_error
        end

        it "should accept Voice" do
          lambda { subject << Voice.new }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << 1 }.should raise_error(InvalidChildError, "A Speak can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
        end
      end

      describe "#to_doc" do
        let(:expected_doc) do
          Nokogiri::XML::Document.new.tap do |doc|
            doc << Speak.new
          end
        end

        it "should create an XML document from the speak" do
          Speak.new.to_doc.to_s.should == expected_doc.to_s
        end
      end

      it "should allow concatenation" do
        speak1 = Speak.new
        speak1 << Voice.new(name: 'frank', content: "Hi, I'm Frank")
        speak2 = Speak.new
        speak2 << Voice.new(name: 'millie', content: "Hi, I'm Millie")

        expected_concat = Speak.new
        expected_concat << Voice.new(name: 'frank', content: "Hi, I'm Frank")
        expected_concat << Voice.new(name: 'millie', content: "Hi, I'm Millie")

        (speak1 + speak2).to_s.should == expected_concat.to_s
      end
    end # Speak
  end # SSML
end # RubySpeech
