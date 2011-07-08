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
            say_as 'date', :format => 'dmy' do
              "01/02/1960"
            end
          end
        end
        voice = SSML::Voice.new(:gender => :male, :name => 'fred', :content => "Hi, I'm Fred. The time is currently ")
        voice << SSML::SayAs.new('date', :format => 'dmy', :content => "01/02/1960")
        expected_doc = SSML::Speak.new
        expected_doc << voice
        doc.should == expected_doc
      end

      it "should allow all permutations of possible nested SSML elements" do
        doc = RubySpeech::SSML.draw do
          string "Hello world."
          ssml_break
          emphasis do
            string "HELLO?"
            ssml_break
            emphasis
            prosody
            say_as 'date'
            voice
          end
          prosody :rate => :slow do
            string "H...E...L...L...O?"
            ssml_break
            emphasis
            prosody
            say_as 'date'
            voice
          end
          say_as 'date', :format => 'dmy' do
            "01/02/1960"
          end
          voice :gender => :male, :name => 'fred' do
            string "Hi, I'm Fred. The time is currently "
            say_as 'date', :format => 'dmy' do
              "01/02/1960"
            end
            ssml_break
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
        emphasis = SSML::Emphasis.new(:content => "HELLO?")
        emphasis << SSML::Break.new
        emphasis << SSML::Emphasis.new
        emphasis << SSML::Prosody.new
        emphasis << SSML::SayAs.new('date')
        emphasis << SSML::Voice.new
        expected_doc << emphasis
        prosody = SSML::Prosody.new(:rate => :slow, :content => "H...E...L...L...O?")
        prosody << SSML::Break.new
        prosody << SSML::Emphasis.new
        prosody << SSML::Prosody.new
        prosody << SSML::SayAs.new('date')
        prosody << SSML::Voice.new
        expected_doc << prosody
        expected_doc << SSML::SayAs.new('date', :format => 'dmy', :content => "01/02/1960")
        voice = SSML::Voice.new(:gender => :male, :name => 'fred', :content => "Hi, I'm Fred. The time is currently ")
        voice << SSML::SayAs.new('date', :format => 'dmy', :content => "01/02/1960")
        voice << SSML::Break.new
        voice << SSML::Emphasis.new(:content => "I'm so old")
        voice << SSML::Prosody.new(:rate => :fast, :content => "And yet so spritely!")
        voice << SSML::Voice.new(:age => 12, :content => "And I'm young Fred")
        expected_doc << voice
        doc.should == expected_doc
      end
    end
  end
end
