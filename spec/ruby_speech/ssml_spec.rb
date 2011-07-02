require 'spec_helper'

module RubySpeech
  describe SSML do
    describe "#draw" do
      it "should create an SSML document" do
        SSML.draw.should == SSML::Speak.new
      end

      describe "when the return value of the block is a string" do
        it "should be inserted into the document" do
          SSML.draw { "Hi, I'm Fred" }.should == SSML::Speak.new(content: "Hi, I'm Fred")
        end
      end

      describe "when the return value of the block is a string" do
        it "should not be inserted into the document" do
          SSML.draw { :foo }.should == SSML::Speak.new
        end
      end

      it "should allow other SSML elements to be inserted in the document" do
        doc = SSML.draw { voice gender: :male, name: 'fred' }
        expected_doc = SSML::Speak.new
        expected_doc << SSML::Voice.new(gender: :male, name: 'fred')
        doc.should == expected_doc
      end

      it "should allow nested block return values" do
        doc = RubySpeech::SSML.draw do
          voice gender: :male, name: 'fred' do
            "Hi, I'm Fred."
          end
        end
        expected_doc = SSML::Speak.new
        expected_doc << SSML::Voice.new(gender: :male, name: 'fred', content: "Hi, I'm Fred.")
        doc.should == expected_doc
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
        expected_doc = SSML::Speak.new
        voice = SSML::Voice.new(gender: :male, name: 'fred', content: "Hi, I'm Fred. The time is currently ")
        voice << SSML::SayAs.new('date', format: 'dmy', content: "01/02/1960")
        expected_doc << voice
        doc.should == expected_doc
      end
    end
  end
end


# RubySpeech::SSML.draw do
#   voice gender: :male, name: 'fred' do
#     text "Hi, I'm Fred. The time is currently "
#     say_as 'date', format: 'dmy' do
#       "01/02/1960"
#     end
#   end
# end
