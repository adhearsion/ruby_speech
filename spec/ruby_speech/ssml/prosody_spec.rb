require 'spec_helper'

module RubySpeech
  module SSML
    describe Prosody do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'prosody' }

      describe "setting options in initializers" do
        subject { Prosody.new doc, :pitch => :medium, :contour => "something", :range => '20Hz', :rate => 2, :duration => 10, :volume => :loud }

        its(:pitch)     { should == :medium }
        its(:contour)   { should == 'something' }
        its(:range)     { should == '20Hz' }
        its(:rate)      { should == 2 }
        its(:duration)  { should eql 10 }
        its(:volume)    { should == :loud }
      end

      it 'registers itself' do
        expect(Element.class_from_registration(:prosody)).to eq(Prosody)
      end

      describe "from a document" do
        let(:document) { '<prosody pitch="medium" contour="something" range="20Hz" rate="2" duration="10" volume="loud"/>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Prosody }

        its(:pitch)     { should == :medium }
        its(:contour)   { should == 'something' }
        its(:range)     { should == '20Hz' }
        its(:rate)      { should == 2 }
        its(:duration)  { should eql 10 }
        its(:volume)    { should == :loud }
      end

      describe "#pitch" do
        context "with a pre-defined value" do
          before { subject.pitch = :medium }

          its(:pitch) { should == :medium }

          it "with a valid value" do
            expect { subject.pitch = :'x-low' }.not_to raise_error
            expect { subject.pitch = :low }.not_to raise_error
            expect { subject.pitch = :medium }.not_to raise_error
            expect { subject.pitch = :high }.not_to raise_error
            expect { subject.pitch = :'x-high' }.not_to raise_error
            expect { subject.pitch = :default }.not_to raise_error
          end

          it "with an invalid value" do
            expect { subject.pitch = :something }.to raise_error(ArgumentError, "You must specify a valid pitch (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
          end
        end

        context "with a Hertz value" do
          describe "with a valid value" do
            before { subject.pitch = '440Hz' }

            its(:pitch) { should == '440Hz' }
          end

          it "with a negative value" do
            expect { subject.pitch = "-100Hz" }.to raise_error(ArgumentError, "You must specify a valid pitch (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
          end

          it "when missing 'hz'" do
            expect { subject.pitch = "440" }.to raise_error(ArgumentError, "You must specify a valid pitch (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
          end
        end
      end

      describe "#contour" do
        before { subject.contour = "blah" }

        its(:contour) { should == "blah" }
      end

      describe "#range" do
        context "with a pre-defined value" do
          before { subject.range = :medium }

          its(:range) { should == :medium }

          it "with a valid value" do
            expect { subject.range = :'x-low' }.not_to raise_error
            expect { subject.range = :low }.not_to raise_error
            expect { subject.range = :medium }.not_to raise_error
            expect { subject.range = :high }.not_to raise_error
            expect { subject.range = :'x-high' }.not_to raise_error
            expect { subject.range = :default }.not_to raise_error
          end

          it "with an invalid value" do
            expect { subject.range = :something }.to raise_error(ArgumentError, "You must specify a valid range (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
          end
        end

        context "with a Hertz value" do
          describe "with a valid value" do
            before { subject.range = '440Hz' }

            its(:range) { should == '440Hz' }
          end

          it "with a negative value" do
            expect { subject.range = "-100Hz" }.to raise_error(ArgumentError, "You must specify a valid range (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
          end

          it "when missing 'hz'" do
            expect { subject.range = "440" }.to raise_error(ArgumentError, "You must specify a valid range (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
          end
        end
      end

      describe "#rate" do
        context "with a pre-defined value" do
          before { subject.rate = :medium }

          its(:rate) { should == :medium }

          it "with a valid value" do
            expect { subject.rate = :'x-slow' }.not_to raise_error
            expect { subject.rate = :slow }.not_to raise_error
            expect { subject.rate = :medium }.not_to raise_error
            expect { subject.rate = :fast }.not_to raise_error
            expect { subject.rate = :'x-fast' }.not_to raise_error
            expect { subject.rate = :default }.not_to raise_error
          end

          it "with an invalid value" do
            expect { subject.rate = :something }.to raise_error(ArgumentError, "You must specify a valid rate ([positive-number](multiplier), :\"x-slow\", :slow, :medium, :fast, :\"x-fast\", :default)")
          end
        end

        context "with a multiplier value" do
          describe "with a valid value" do
            before { subject.rate = 1.5 }

            its(:rate) { should == 1.5 }
          end

          it "with a negative value" do
            expect { subject.rate = -100 }.to raise_error(ArgumentError, "You must specify a valid rate ([positive-number](multiplier), :\"x-slow\", :slow, :medium, :fast, :\"x-fast\", :default)")
          end

          describe "with a percentage" do
            before { subject.rate = "22.5%" }

            its(:rate) { should == "22.5%" }
          end

          describe "with a percentage and a plus sign" do
            before { subject.rate = "+22.5%" }

            its(:rate) { should == "+22.5%" }
          end

          describe "with a percentage and a minus sign" do
            before { subject.rate = "-22.5%" }

            its(:rate) { should == "-22.5%" }
          end
        end
      end

      describe "#duration" do
        context "with a valid value" do
          before { subject.duration = 3 }

          its(:duration) { should eql 3 }
        end

        context "with a negative value" do
          it do
            expect { subject.duration = -3 }.to raise_error(ArgumentError, "You must specify a valid duration (positive float value in seconds)")
          end
        end

        context "with an invalid value" do
          it do
            expect { subject.duration = 'blah' }.to raise_error(ArgumentError, "You must specify a valid duration (positive float value in seconds)")
          end
        end
      end

      describe "#volume" do
        context "with a pre-defined value" do
          before { subject.volume = :medium }

          its(:volume) { should == :medium }

          it "with a valid value" do
            expect { subject.volume = :silent }.not_to raise_error
            expect { subject.volume = :'x-soft' }.not_to raise_error
            expect { subject.volume = :soft }.not_to raise_error
            expect { subject.volume = :medium }.not_to raise_error
            expect { subject.volume = :loud }.not_to raise_error
            expect { subject.volume = :'x-loud' }.not_to raise_error
            expect { subject.volume = :default }.not_to raise_error
          end

          it "with an invalid value" do
            expect { subject.volume = :something }.to raise_error(ArgumentError, "You must specify a valid volume ([positive-number](0.0 -> 100.0), :silent, :\"x-soft\", :soft, :medium, :loud, :\"x-loud\", :default)")
          end
        end

        context "with a multiplier" do
          describe "with a valid value" do
            before { subject.volume = 1.5 }

            its(:volume) { should == 1.5 }
          end

          it "with a negative value" do
            expect { subject.volume = -1.5 }.to raise_error(ArgumentError, "You must specify a valid volume ([positive-number](0.0 -> 100.0), :silent, :\"x-soft\", :soft, :medium, :loud, :\"x-loud\", :default)")
            expect { subject.volume = 100.5 }.to raise_error(ArgumentError, "You must specify a valid volume ([positive-number](0.0 -> 100.0), :silent, :\"x-soft\", :soft, :medium, :loud, :\"x-loud\", :default)")
          end
        end
      end

      describe "comparing objects" do
        it "should be equal if the content, strength and base uri are the same" do
          expect(Prosody.new(doc, :pitch => :medium, :contour => "something", :range => '20Hz', :rate => 2, :duration => 10, :volume => :loud, :content => "Hello there")).to eq(Prosody.new(doc, :pitch => :medium, :contour => "something", :range => '20Hz', :rate => 2, :duration => 10, :volume => :loud, :content => "Hello there"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Prosody.new(doc, :content => "Hello")).not_to eq(Prosody.new(doc, :content => "Hello there"))
          end
        end

        describe "when the pitch is different" do
          it "should not be equal" do
            expect(Prosody.new(doc, :pitch => :medium)).not_to eq(Prosody.new(doc, :pitch => :high))
          end
        end

        describe "when the contour is different" do
          it "should not be equal" do
            expect(Prosody.new(doc, :contour => 'foo')).not_to eq(Prosody.new(doc, :contour => 'bar'))
          end
        end

        describe "when the range is different" do
          it "should not be equal" do
            expect(Prosody.new(doc, :range => '20Hz')).not_to eq(Prosody.new(doc, :range => '30Hz'))
          end
        end

        describe "when the rate is different" do
          it "should not be equal" do
            expect(Prosody.new(doc, :rate => 2)).not_to eq(Prosody.new(doc, :rate => 3))
          end
        end

        describe "when the duration is different" do
          it "should not be equal" do
            expect(Prosody.new(doc, :duration => 10)).not_to eq(Prosody.new(doc, :duration => 20))
          end
        end

        describe "when the volume is different" do
          it "should not be equal" do
            expect(Prosody.new(doc, :volume => :loud)).not_to eq(Prosody.new(doc, :volume => :soft))
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

        it "should accept P" do
          expect { subject << P.new(doc) }.not_to raise_error
        end

        it "should accept Phoneme" do
          expect { subject << Phoneme.new(doc) }.not_to raise_error
        end

        it "should accept Prosody" do
          expect { subject << Prosody.new(doc) }.not_to raise_error
        end

        it "should accept S" do
          expect { subject << S.new(doc) }.not_to raise_error
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
          expect { subject << 1 }.to raise_error(InvalidChildError, "A Prosody can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
        end
      end
    end # Prosody
  end # SSML
end # RubySpeech
