require 'spec_helper'

module RubySpeech
  describe SSML do
    describe "#draw" do
      let(:expected_doc) { Nokogiri::XML::Document.new }

      it "should create an SSML document" do
        expected_doc << SSML::Speak.new
        SSML.draw.should == expected_doc.to_s
      end

      describe "when the return value of the block is a string" do
        it "should be inserted into the document" do
          expected_doc << SSML::Speak.new(content: "Hi, I'm Fred")
          SSML.draw { "Hi, I'm Fred" }.should == expected_doc.to_s
        end
      end

      describe "when the return value of the block is a string" do
        it "should not be inserted into the document" do
          expected_doc << SSML::Speak.new
          SSML.draw { :foo }.should == expected_doc.to_s
        end
      end

      it "should allow other SSML elements to be inserted in the document" do
        doc = SSML.draw { voice gender: :male, name: 'fred' }
        speak = SSML::Speak.new
        speak << SSML::Voice.new(gender: :male, name: 'fred')
        expected_doc << speak
        doc.should == expected_doc.to_s
      end

      it "should allow nested block return values" do
        doc = RubySpeech::SSML.draw do
          voice gender: :male, name: 'fred' do
            "Hi, I'm Fred."
          end
        end
        speak = SSML::Speak.new
        speak << SSML::Voice.new(gender: :male, name: 'fred', content: "Hi, I'm Fred.")
        expected_doc << speak
        doc.should == expected_doc.to_s
      end

      it "should allow nested SSML elements" do
        doc = RubySpeech::SSML.draw do
          voice gender: :male, name: 'fred' do
            string "Hi, I'm Fred. The time is currently "
            say_as 'date', format: 'dmy' do
              "01/02/1960"
            end
          end
        end
        speak = SSML::Speak.new
        voice = SSML::Voice.new(gender: :male, name: 'fred', content: "Hi, I'm Fred. The time is currently ")
        voice << SSML::SayAs.new('date', format: 'dmy', content: "01/02/1960")
        speak << voice
        expected_doc << speak
        doc.should == expected_doc.to_s
      end
    end
  end
end
