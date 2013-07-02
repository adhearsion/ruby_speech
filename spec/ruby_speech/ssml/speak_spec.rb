require 'spec_helper'

module RubySpeech
  module SSML
    describe Speak do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      it { should be_a_valid_ssml_document }

      its(:name) { should == 'speak' }
      its(:language) { should == 'en-US' }

      describe "setting options in initializers" do
        subject { Speak.new doc, :language => 'jp', :base_uri => 'blah' }

        its(:language) { should == 'jp' }
        its(:base_uri) { should == 'blah' }
      end

      it 'registers itself' do
        Element.class_from_registration(:speak).should == Speak
      end

      describe "from a document" do
        let(:document) { '<speak xmlns="http://www.w3.org/2001/10/synthesis" version="1.0" xml:lang="jp" xml:base="blah"/>' }

        subject { Element.import document }

        it { should be_instance_of Speak }

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
          Speak.new(doc, :language => 'en-GB', :base_uri => 'blah', :content => "Hello there").should == Speak.new(doc, :language => 'en-GB', :base_uri => 'blah', :content => "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Speak.new(doc, :content => "Hello").should_not == Speak.new(doc, :content => "Hello there")
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            Speak.new(doc, :language => 'en-US').should_not == Speak.new(doc, :language => 'en-GB')
          end
        end

        describe "when the base URI is different" do
          it "should not be equal" do
            Speak.new(doc, :base_uri => 'foo').should_not == Speak.new(doc, :base_uri => 'bar')
          end
        end

        describe "when the children are different" do
          it "should not be equal" do
            s1 = Speak.new doc
            s1 << SayAs.new(doc, :interpret_as => 'date')
            s2 = Speak.new doc
            s2 << SayAs.new(doc, :interpret_as => 'time')

            s1.should_not == s2
          end
        end
      end

      it "should allow creating child SSML elements" do
        s = Speak.new doc
        s.voice :gender => :male, :content => 'Hello'
        expected_s = Speak.new doc
        expected_s << Voice.new(doc, :gender => :male, :content => 'Hello')
        s.should == expected_s
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

        it "should accept P" do
          lambda { subject << P.new(doc) }.should_not raise_error
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
          lambda { subject << 1 }.should raise_error(InvalidChildError, "A Speak can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
        end
      end

      describe "#to_doc" do
        it "should create an XML document from the grammar" do
          subject.to_doc.should == subject.document
        end
      end

      it "should allow concatenation" do
        speak1 = SSML.draw do
          voice :name => 'frank' do
            "Hi, I'm Frank"
          end
        end
        speak1_string = speak1.to_s

        speak2 = SSML.draw do
          string "Hello there"
          voice :name => 'millie' do
            "Hi, I'm Millie"
          end
        end
        speak2_string = speak2.to_s

        expected_concat = SSML.draw do
          voice :name => 'frank' do
            "Hi, I'm Frank"
          end
          string "Hello there"
          voice :name => 'millie' do
            "Hi, I'm Millie"
          end
        end

        concat = (speak1 + speak2)
        speak1.to_s.should == speak1_string
        speak2.to_s.should == speak2_string
        concat.should == expected_concat
        concat.document.root.should == concat
        concat.to_s.should_not include('default')
      end
    end # Speak
  end # SSML
end # RubySpeech
