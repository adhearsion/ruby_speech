require 'spec_helper'

module RubySpeech
  module SSML
    describe Voice do
      its(:node_name) { should == 'voice' }
      its(:name) { should be_nil }

      describe "setting options in initializers" do
        subject { Voice.new :language => 'jp', :gender => :male, :age => 25, :variant => 2, :name => "paul" }

        its(:language)  { should == 'jp' }
        its(:gender)    { should == :male }
        its(:age)       { should == 25 }
        its(:variant)   { should == 2 }
        its(:name)      { should == 'paul' }
      end

      describe "#language" do
        before { subject.language = 'jp' }

        its(:language) { should == 'jp' }
      end

      describe "#gender" do
        before { subject.gender = :male }

        its(:gender) { should == :male }

        it "with a valid gender" do
          lambda { subject.gender = :male }.should_not raise_error
          lambda { subject.gender = :female }.should_not raise_error
          lambda { subject.gender = :neutral }.should_not raise_error
        end

        it "with an invalid gender" do
          lambda { subject.gender = :something }.should raise_error(ArgumentError, "You must specify a valid gender (:male, :female, :neutral)")
        end
      end

      describe "#age" do
        before { subject.age = 12 }

        its(:age) { should == 12 }

        it "with an integer of 0" do
          lambda { subject.age = 0 }.should_not raise_error
        end

        it "with an integer less than 0" do
          lambda { subject.age = -1 }.should raise_error(ArgumentError, "You must specify a valid age (non-negative integer)")
        end

        it "with something other than an integer" do
          lambda { subject.age = "bah" }.should raise_error(ArgumentError, "You must specify a valid age (non-negative integer)")
        end
      end

      describe "#variant" do
        before { subject.variant = 12 }

        its(:variant) { should == 12 }

        it "with an integer less than 1" do
          lambda { subject.variant = 0 }.should raise_error(ArgumentError, "You must specify a valid variant (positive integer)")
        end

        it "with something other than an integer" do
          lambda { subject.variant = "bah" }.should raise_error(ArgumentError, "You must specify a valid variant (positive integer)")
        end
      end

      describe "#name" do
        before { subject.name = 'george' }

        its(:name) { should == 'george' }

        context "with an array of names" do
          before { subject.name = %w{george frank} }

          its(:name) { should == %w{george frank} }
        end
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
          pending
          lambda { subject << SayAs.new }.should_not raise_error
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
          lambda { subject << 1 }.should raise_error(InvalidChildError, "A Voice can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
        end
      end

      # TODO: The voice element can only contain text to be rendered and the following elements: audio, break, emphasis, mark, p, phoneme, prosody, say-as, sub, s, voice.
    end # Voice
  end # SSML
end # RubySpeech
