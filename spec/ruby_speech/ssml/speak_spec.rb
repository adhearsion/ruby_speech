require 'spec_helper'

module RubySpeech
  module SSML
    describe Speak do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      it { is_expected.to be_a_valid_ssml_document }

      its(:name) { should == 'speak' }
      its(:language) { should == 'en-US' }

      describe "setting options in initializers" do
        subject { Speak.new doc, :language => 'jp', :base_uri => 'blah' }

        its(:language) { should == 'jp' }
        its(:base_uri) { should == 'blah' }
      end

      it 'registers itself' do
        expect(Element.class_from_registration(:speak)).to eq(Speak)
      end

      describe "from a document" do
        let(:document) { '<speak xmlns="http://www.w3.org/2001/10/synthesis" version="1.0" xml:lang="jp" xml:base="blah"/>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Speak }

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
          expect(Speak.new(doc, :language => 'en-GB', :base_uri => 'blah', :content => "Hello there")).to eq(Speak.new(doc, :language => 'en-GB', :base_uri => 'blah', :content => "Hello there"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Speak.new(doc, :content => "Hello")).not_to eq(Speak.new(doc, :content => "Hello there"))
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            expect(Speak.new(doc, :language => 'en-US')).not_to eq(Speak.new(doc, :language => 'en-GB'))
          end
        end

        describe "when the base URI is different" do
          it "should not be equal" do
            expect(Speak.new(doc, :base_uri => 'foo')).not_to eq(Speak.new(doc, :base_uri => 'bar'))
          end
        end

        describe "when the children are different" do
          it "should not be equal" do
            s1 = Speak.new doc
            s1 << SayAs.new(doc, :interpret_as => 'date')
            s2 = Speak.new doc
            s2 << SayAs.new(doc, :interpret_as => 'time')

            expect(s1).not_to eq(s2)
          end
        end
      end

      it "should allow creating child SSML elements" do
        s = Speak.new doc
        s.voice :gender => :male, :content => 'Hello'
        expected_s = Speak.new doc
        expected_s << Voice.new(doc, :gender => :male, :content => 'Hello')
        expect(s).to eq(expected_s)
      end

      describe "<<" do
        it "should accept String" do
          expect { subject << 'anything' }.not_to raise_error
        end

        it "should accept Audio" do
          expect { subject << Audio.new(doc) }.not_to raise_error
        end

        it "should accept Break" do
          expect { subject << Break.new(doc) }.not_to raise_error
        end

        it "should accept Emphasis" do
          expect { subject << Emphasis.new(doc) }.not_to raise_error
        end

        it "should accept Mark" do
          expect { subject << Mark.new(doc) }.not_to raise_error
        end

        it "should accept P" do
          expect { subject << P.new(doc) }.not_to raise_error
        end

        it "should accept Phoneme" do
          expect { subject << Phoneme.new(doc) }.not_to raise_error
        end

        it "should accept Prosody" do
          expect { subject << Prosody.new(doc) }.not_to raise_error
        end

        it "should accept SayAs" do
          expect { subject << SayAs.new(doc, :interpret_as => :foo) }.not_to raise_error
        end

        it "should accept Sub" do
          expect { subject << Sub.new(doc) }.not_to raise_error
        end

        it "should accept S" do
          expect { subject << S.new(doc) }.not_to raise_error
        end

        it "should accept Voice" do
          expect { subject << Voice.new(doc) }.not_to raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          expect { subject << 1 }.to raise_error(InvalidChildError, "A Speak can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
        end
      end

      describe "#to_doc" do
        it "should create an XML document from the grammar" do
          expect(subject.to_doc).to eq(subject.document)
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
        expect(speak1.to_s).to eq(speak1_string)
        expect(speak2.to_s).to eq(speak2_string)
        expect(concat).to eq(expected_concat)
        expect(concat.document.root).to eq(concat)
        expect(concat.to_s).not_to include('default')
      end

      context "when concatenating" do
        describe "simple strings" do
          it "inserts a space between them" do
            speak1 = SSML.draw do
              string "Hi, my name"
            end

            speak2 = SSML.draw do
              string "is Frank"
            end

            expected_concat = SSML.draw do
              string "Hi, my name is Frank"
            end

            concat = (speak1 + speak2)
            expect(concat).to eq(expected_concat)
          end
        end
      end
    end # Speak
  end # SSML
end # RubySpeech
