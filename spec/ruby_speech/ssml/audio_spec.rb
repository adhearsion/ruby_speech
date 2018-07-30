require 'spec_helper'

module RubySpeech
  module SSML
    describe Audio do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'audio' }

      describe "setting options in initializers" do
        subject { Audio.new doc, :src => 'http://whatever.you-say-boss.com', :content => 'Hello' }

        its(:src)     { should == 'http://whatever.you-say-boss.com' }
        its(:content) { should == 'Hello' }
      end

      it 'registers itself' do
        expect(Element.class_from_registration(:audio)).to eq(Audio)
      end

      describe "from a document" do
        let(:document) { '<audio src="http://whatever.you-say-boss.com">Hello</audio>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Audio }

        its(:src)     { should == 'http://whatever.you-say-boss.com' }
        its(:content) { should == 'Hello' }
      end

      describe "#src" do
        before { subject.src = 'http://whatever.you-say-boss.com' }

        its(:src) { should == 'http://whatever.you-say-boss.com' }
      end

      describe "#content" do
        context "with a valid value" do
          before { subject.content = "Hello" }

          its(:content) { should == "Hello" }
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

        it "should accept Desc" do
          expect { subject << Desc.new(doc) }.not_to raise_error
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
          expect { subject << 1 }.to raise_error(InvalidChildError, "An Audio can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
        end
      end

      describe "comparing objects" do
        it "should be equal if the content, and src are the same" do
          expect(Audio.new(doc, :src => "one", :content => "Hello there")).to eq(Audio.new(doc, :src => "one", :content => "Hello there"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Audio.new(doc, :content => "Hello")).not_to eq(Audio.new(doc, :content => "Hello there"))
          end
        end

        describe "when the src is different" do
          it "should not be equal" do
            expect(Audio.new(doc, :src => 'one')).not_to eq(Audio.new(doc, :src => 'two'))
          end
        end
      end
    end # Break
  end # SSML
end # RubySpeech
