require 'spec_helper'

module RubySpeech
  module SSML
    describe S do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 's' }

      describe "setting options in initializers" do
        subject { S.new doc, :language => 'jp' }

        its(:language) { should == 'jp' }
      end

      it 'registers itself' do
        expect(Element.class_from_registration(:s)).to eq(S)
      end

      describe "from a document" do
        let(:document) { '<s>foo</s>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of S }
        its(:content) { should == 'foo' }
      end

      describe "comparing objects" do
        it "should be equal if the content and language are the same" do
          expect(S.new(doc, :language => 'jp', :content => "Hello there")).to eq(S.new(doc, :language => 'jp', :content => "Hello there"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(S.new(doc, :content => "Hello")).not_to eq(S.new(doc, :content => "Hello there"))
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            expect(S.new(doc, :language => 'jp')).not_to eq(S.new(doc, :language => 'en'))
          end
        end
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

        it "should accept Voice" do
          expect { subject << Voice.new(doc) }.not_to raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          expect { subject << 1 }.to raise_error(InvalidChildError, "An S can only accept String, Audio, Break, Emphasis, Mark, Phoneme, Prosody, SayAs, Sub, Voice as children")
        end
      end
    end # S
  end # SSML
end # RubySpeech
