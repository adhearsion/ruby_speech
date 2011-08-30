require 'spec_helper'

module RubySpeech
  describe SSML do
    describe "#draw" do
      it "should create an SSML document" do
        expected_doc = SSML::Speak.new
        SSML.draw.should == expected_doc
      end

      describe "when the return value of the block is a string" do
        it "should be inserted into the document" do
          expected_doc = SSML::Speak.new(:content => "Hi, I'm Fred")
          SSML.draw { "Hi, I'm Fred" }.should == expected_doc
        end
      end

      describe "when the return value of the block is a string" do
        it "should not be inserted into the document" do
          expected_doc = SSML::Speak.new
          SSML.draw { :foo }.should == expected_doc
        end
      end

      it "should allow other SSML elements to be inserted in the document" do
        doc = SSML.draw { voice :gender => :male, :name => 'fred' }
        expected_doc = SSML::Speak.new
        expected_doc << SSML::Voice.new(:gender => :male, :name => 'fred')
        doc.should == expected_doc
      end

      it "should allow nested block return values" do
        doc = RubySpeech::SSML.draw do
          voice :gender => :male, :name => 'fred' do
            "Hi, I'm Fred."
          end
        end
        expected_doc = SSML::Speak.new
        expected_doc << SSML::Voice.new(:gender => :male, :name => 'fred', :content => "Hi, I'm Fred.")
        doc.should == expected_doc
      end

      it "should allow nested SSML elements" do
        doc = RubySpeech::SSML.draw do
          voice :gender => :male, :name => 'fred' do
            string "Hi, I'm Fred. The time is currently "
            say_as :interpret_as => 'date', :format => 'dmy' do
              "01/02/1960"
            end
          end
        end
        voice = SSML::Voice.new(:gender => :male, :name => 'fred', :content => "Hi, I'm Fred. The time is currently ")
        voice << SSML::SayAs.new(:interpret_as => 'date', :format => 'dmy', :content => "01/02/1960")
        expected_doc = SSML::Speak.new
        expected_doc << voice
        doc.should == expected_doc
      end

      it "should properly escape string input" do
        doc = RubySpeech::SSML.draw do
          voice { string "I <3 nachos." }
          voice { "I <3 nachos." }
        end
        expected_doc = SSML::Speak.new
        2.times do
          expected_doc << SSML::Voice.new(:content => "I <3 nachos.")
        end
        doc.should == expected_doc
      end

      it "should allow all permutations of possible nested SSML elements" do
        doc = RubySpeech::SSML.draw do
          string "Hello world."
          ssml_break
          audio :src => "hello" do
            string "HELLO?"
            ssml_break
            audio :src => "hello"
            emphasis
            prosody
            say_as :interpret_as => 'date'
            voice
          end
          emphasis do
            string "HELLO?"
            ssml_break
            audio :src => "hello"
            emphasis
            prosody
            say_as :interpret_as => 'date'
            voice
          end
          prosody :rate => :slow do
            string "H...E...L...L...O?"
            ssml_break
            audio :src => "hello"
            emphasis
            prosody
            say_as :interpret_as => 'date'
            voice
          end
          say_as :interpret_as => 'date', :format => 'dmy' do
            "01/02/1960"
          end
          voice :gender => :male, :name => 'fred' do
            string "Hi, I'm Fred. The time is currently "
            say_as :interpret_as => 'date', :format => 'dmy' do
              "01/02/1960"
            end
            ssml_break
            audio :src => "hello"
            emphasis do
              "I'm so old"
            end
            prosody :rate => :fast do
              "And yet so spritely!"
            end
            voice :age => 12 do
              "And I'm young Fred"
            end
          end
        end
        expected_doc = SSML::Speak.new(:content => "Hello world.")
        expected_doc << SSML::Break.new
        audio = SSML::Audio.new(:src => "hello", :content => "HELLO?")
        audio << SSML::Break.new
        audio << SSML::Audio.new(:src => "hello")
        audio << SSML::Emphasis.new
        audio << SSML::Prosody.new
        audio << SSML::SayAs.new(:interpret_as => 'date')
        audio << SSML::Voice.new
        expected_doc << audio
        emphasis = SSML::Emphasis.new(:content => "HELLO?")
        emphasis << SSML::Break.new
        emphasis << SSML::Audio.new(:src => "hello")
        emphasis << SSML::Emphasis.new
        emphasis << SSML::Prosody.new
        emphasis << SSML::SayAs.new(:interpret_as => 'date')
        emphasis << SSML::Voice.new
        expected_doc << emphasis
        prosody = SSML::Prosody.new(:rate => :slow, :content => "H...E...L...L...O?")
        prosody << SSML::Break.new
        prosody << SSML::Audio.new(:src => "hello")
        prosody << SSML::Emphasis.new
        prosody << SSML::Prosody.new
        prosody << SSML::SayAs.new(:interpret_as => 'date')
        prosody << SSML::Voice.new
        expected_doc << prosody
        expected_doc << SSML::SayAs.new(:interpret_as => 'date', :format => 'dmy', :content => "01/02/1960")
        voice = SSML::Voice.new(:gender => :male, :name => 'fred', :content => "Hi, I'm Fred. The time is currently ")
        voice << SSML::SayAs.new(:interpret_as => 'date', :format => 'dmy', :content => "01/02/1960")
        voice << SSML::Break.new
        voice << SSML::Audio.new(:src => "hello")
        voice << SSML::Emphasis.new(:content => "I'm so old")
        voice << SSML::Prosody.new(:rate => :fast, :content => "And yet so spritely!")
        voice << SSML::Voice.new(:age => 12, :content => "And I'm young Fred")
        expected_doc << voice
        doc.should == expected_doc
      end
    end

    describe "importing nested tags" do
      let(:say_as) { SSML::SayAs.new :interpret_as => 'date', :format => 'dmy', :content => "01/02/1960" }
      let(:string) { "Hi, I'm Fred. The time is currently " }
      let :voice do
        SSML::Voice.new(:gender => :male, :name => 'fred', :content => string).tap do |voice|
          voice << say_as
        end
      end

      let :document do
        SSML::Speak.new.tap { |doc| doc << voice }.to_s
      end

      let(:import) { SSML::Element.import parse_xml(document).root }

      subject { import }

      it "should work" do
        lambda { subject }.should_not raise_error
      end

      it { should be_a SSML::Speak }

      its(:children) { should == [voice] }

      describe "voice" do
        subject { import.children.first }

        its(:children) { should == [string, say_as] }
      end
    end
  end
end
