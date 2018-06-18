require 'spec_helper'

module RubySpeech
  module SSML
    describe Emphasis do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'emphasis' }

      describe "setting options in initializers" do
        subject { Emphasis.new doc, :level => :strong }

        its(:level) { should == :strong }
      end

      it 'registers itself' do
        expect(Element.class_from_registration(:emphasis)).to eq(Emphasis)
      end

      describe "from a document" do
        let(:document) { '<emphasis level="strong"/>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Emphasis }

        its(:level) { should == :strong }
      end

      describe "#level" do
        before { subject.level = :strong }

        its(:level) { should == :strong }

        it "with a valid level" do
          expect { subject.level = :strong }.not_to raise_error
          expect { subject.level = :moderate }.not_to raise_error
          expect { subject.level = :none }.not_to raise_error
          expect { subject.level = :reduced }.not_to raise_error
        end

        it "with an invalid level" do
          expect { subject.level = :something }.to raise_error(ArgumentError, "You must specify a valid level (:strong, :moderate, :none, :reduced)")
        end
      end

      describe "comparing objects" do
        it "should be equal if the content and level are the same" do
          expect(Emphasis.new(doc, :level => :strong, :content => "Hello there")).to eq(Emphasis.new(doc, :level => :strong, :content => "Hello there"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Emphasis.new(doc, :content => "Hello")).not_to eq(Emphasis.new(doc, :content => "Hello there"))
          end
        end

        describe "when the level is different" do
          it "should not be equal" do
            expect(Emphasis.new(doc, :level => :strong)).not_to eq(Emphasis.new(doc, :level => :reduced))
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
          expect { subject << 1 }.to raise_error(InvalidChildError, "An Emphasis can only accept String, Audio, Break, Emphasis, Mark, Phoneme, Prosody, SayAs, Sub, Voice as children")
        end
      end
    end # Emphasis
  end # SSML
end # RubySpeech
