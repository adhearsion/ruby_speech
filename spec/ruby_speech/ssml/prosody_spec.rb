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
        its(:duration)  { should == 10 }
        its(:volume)    { should == :loud }
      end

      it 'registers itself' do
        Element.class_from_registration(:prosody).should == Prosody
      end

      describe "from a document" do
        let(:document) { '<prosody pitch="medium" contour="something" range="20Hz" rate="2" duration="10" volume="loud"/>' }

        subject { Element.import document }

        it { should be_instance_of Prosody }

        its(:pitch)     { should == :medium }
        its(:contour)   { should == 'something' }
        its(:range)     { should == '20Hz' }
        its(:rate)      { should == 2 }
        its(:duration)  { should == 10 }
        its(:volume)    { should == :loud }
      end

      describe "#pitch" do
        context "with a pre-defined value" do
          before { subject.pitch = :medium }

          its(:pitch) { should == :medium }

          it "with a valid value" do
            lambda { subject.pitch = :'x-low' }.should_not raise_error
            lambda { subject.pitch = :low }.should_not raise_error
            lambda { subject.pitch = :medium }.should_not raise_error
            lambda { subject.pitch = :high }.should_not raise_error
            lambda { subject.pitch = :'x-high' }.should_not raise_error
            lambda { subject.pitch = :default }.should_not raise_error
          end

          it "with an invalid value" do
            lambda { subject.pitch = :something }.should raise_error(ArgumentError, "You must specify a valid pitch (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
          end
        end

        context "with a Hertz value" do
          describe "with a valid value" do
            before { subject.pitch = '440Hz' }

            its(:pitch) { should == '440Hz' }
          end

          it "with a negative value" do
            lambda { subject.pitch = "-100Hz" }.should raise_error(ArgumentError, "You must specify a valid pitch (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
          end

          it "when missing 'hz'" do
            lambda { subject.pitch = "440" }.should raise_error(ArgumentError, "You must specify a valid pitch (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
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
            lambda { subject.range = :'x-low' }.should_not raise_error
            lambda { subject.range = :low }.should_not raise_error
            lambda { subject.range = :medium }.should_not raise_error
            lambda { subject.range = :high }.should_not raise_error
            lambda { subject.range = :'x-high' }.should_not raise_error
            lambda { subject.range = :default }.should_not raise_error
          end

          it "with an invalid value" do
            lambda { subject.range = :something }.should raise_error(ArgumentError, "You must specify a valid range (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
          end
        end

        context "with a Hertz value" do
          describe "with a valid value" do
            before { subject.range = '440Hz' }

            its(:range) { should == '440Hz' }
          end

          it "with a negative value" do
            lambda { subject.range = "-100Hz" }.should raise_error(ArgumentError, "You must specify a valid range (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
          end

          it "when missing 'hz'" do
            lambda { subject.range = "440" }.should raise_error(ArgumentError, "You must specify a valid range (\"[positive-number]Hz\", :\"x-low\", :low, :medium, :high, :\"x-high\", :default)")
          end
        end
      end

      describe "#rate" do
        context "with a pre-defined value" do
          before { subject.rate = :medium }

          its(:rate) { should == :medium }

          it "with a valid value" do
            lambda { subject.rate = :'x-slow' }.should_not raise_error
            lambda { subject.rate = :slow }.should_not raise_error
            lambda { subject.rate = :medium }.should_not raise_error
            lambda { subject.rate = :fast }.should_not raise_error
            lambda { subject.rate = :'x-fast' }.should_not raise_error
            lambda { subject.rate = :default }.should_not raise_error
          end

          it "with an invalid value" do
            lambda { subject.rate = :something }.should raise_error(ArgumentError, "You must specify a valid rate ([positive-number](multiplier), :\"x-slow\", :slow, :medium, :fast, :\"x-fast\", :default)")
          end
        end

        context "with a multiplier value" do
          describe "with a valid value" do
            before { subject.rate = 1.5 }

            its(:rate) { should == 1.5 }
          end

          it "with a negative value" do
            lambda { subject.rate = -100 }.should raise_error(ArgumentError, "You must specify a valid rate ([positive-number](multiplier), :\"x-slow\", :slow, :medium, :fast, :\"x-fast\", :default)")
          end
        end
      end

      describe "#duration" do
        context "with a valid value" do
          before { subject.duration = 3 }

          its(:duration) { should == 3 }
        end

        context "with a negative value" do
          it do
            lambda { subject.duration = -3 }.should raise_error(ArgumentError, "You must specify a valid duration (positive float value in seconds)")
          end
        end

        context "with an invalid value" do
          it do
            lambda { subject.duration = 'blah' }.should raise_error(ArgumentError, "You must specify a valid duration (positive float value in seconds)")
          end
        end
      end

      describe "#volume" do
        context "with a pre-defined value" do
          before { subject.volume = :medium }

          its(:volume) { should == :medium }

          it "with a valid value" do
            lambda { subject.volume = :silent }.should_not raise_error
            lambda { subject.volume = :'x-soft' }.should_not raise_error
            lambda { subject.volume = :soft }.should_not raise_error
            lambda { subject.volume = :medium }.should_not raise_error
            lambda { subject.volume = :loud }.should_not raise_error
            lambda { subject.volume = :'x-loud' }.should_not raise_error
            lambda { subject.volume = :default }.should_not raise_error
          end

          it "with an invalid value" do
            lambda { subject.volume = :something }.should raise_error(ArgumentError, "You must specify a valid volume ([positive-number](0.0 -> 100.0), :silent, :\"x-soft\", :soft, :medium, :loud, :\"x-loud\", :default)")
          end
        end

        context "with a multiplier" do
          describe "with a valid value" do
            before { subject.volume = 1.5 }

            its(:volume) { should == 1.5 }
          end

          it "with a negative value" do
            lambda { subject.volume = -1.5 }.should raise_error(ArgumentError, "You must specify a valid volume ([positive-number](0.0 -> 100.0), :silent, :\"x-soft\", :soft, :medium, :loud, :\"x-loud\", :default)")
            lambda { subject.volume = 100.5 }.should raise_error(ArgumentError, "You must specify a valid volume ([positive-number](0.0 -> 100.0), :silent, :\"x-soft\", :soft, :medium, :loud, :\"x-loud\", :default)")
          end
        end
      end

      describe "comparing objects" do
        it "should be equal if the content, strength and base uri are the same" do
          Prosody.new(doc, :pitch => :medium, :contour => "something", :range => '20Hz', :rate => 2, :duration => 10, :volume => :loud, :content => "Hello there").should == Prosody.new(doc, :pitch => :medium, :contour => "something", :range => '20Hz', :rate => 2, :duration => 10, :volume => :loud, :content => "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Prosody.new(doc, :content => "Hello").should_not == Prosody.new(doc, :content => "Hello there")
          end
        end

        describe "when the pitch is different" do
          it "should not be equal" do
            Prosody.new(doc, :pitch => :medium).should_not == Prosody.new(doc, :pitch => :high)
          end
        end

        describe "when the contour is different" do
          it "should not be equal" do
            Prosody.new(doc, :contour => 'foo').should_not == Prosody.new(doc, :contour => 'bar')
          end
        end

        describe "when the range is different" do
          it "should not be equal" do
            Prosody.new(doc, :range => '20Hz').should_not == Prosody.new(doc, :range => '30Hz')
          end
        end

        describe "when the rate is different" do
          it "should not be equal" do
            Prosody.new(doc, :rate => 2).should_not == Prosody.new(doc, :rate => 3)
          end
        end

        describe "when the duration is different" do
          it "should not be equal" do
            Prosody.new(doc, :duration => 10).should_not == Prosody.new(doc, :duration => 20)
          end
        end

        describe "when the volume is different" do
          it "should not be equal" do
            Prosody.new(doc, :volume => :loud).should_not == Prosody.new(doc, :volume => :soft)
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

        it "should accept P" do
          lambda { subject << P.new(doc) }.should_not raise_error
        end

        it "should accept Phoneme" do
          lambda { subject << Phoneme.new(doc) }.should_not raise_error
        end

        it "should accept Prosody" do
          lambda { subject << Prosody.new(doc) }.should_not raise_error
        end

        it "should accept S" do
          lambda { subject << S.new(doc) }.should_not raise_error
        end

        it "should accept SayAs" do
          lambda { subject << SayAs.new(doc, :interpret_as => :foo) }.should_not raise_error
        end

        it "should accept Sub" do
          lambda { subject << Sub.new(doc) }.should_not raise_error
        end

        it "should accept Voice" do
          lambda { subject << Voice.new(doc) }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << 1 }.should raise_error(InvalidChildError, "A Prosody can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
        end
      end
    end # Prosody
  end # SSML
end # RubySpeech
