require 'spec_helper'

module RubySpeech
  describe SSML do
    describe "#draw" do
      let(:doc) { Nokogiri::XML::Document.new }

      it "should create an SSML document" do
        expected_doc = SSML::Speak.new doc
        SSML.draw.should == expected_doc
        SSML.draw.document.xpath('ns:speak', ns: 'http://www.w3.org/2001/10/synthesis').size.should == 1
      end

      it "can draw with a language" do
        expected_doc = SSML::Speak.new doc, language: 'pt-BR'
        SSML.draw(language: 'pt-BR').should == expected_doc
      end

      describe "when the return value of the block is a string" do
        it "should be inserted into the document" do
          expected_doc = SSML::Speak.new(doc, :content => "Hi, I'm Fred")
          SSML.draw { "Hi, I'm Fred" }.should == expected_doc
        end
      end

      describe "when the return value of the block is not a string" do
        it "should not be inserted into the document" do
          expected_doc = SSML::Speak.new doc
          SSML.draw { :foo }.should == expected_doc
        end
      end

      describe "when inserting a string" do
        it "should work" do
          expected_doc = SSML::Speak.new(doc, :content => "Hi, I'm Fred")
          SSML.draw { string "Hi, I'm Fred" }.should == expected_doc
        end
      end

      it "should allow other SSML elements to be inserted in the document" do
        expected_doc = SSML::Speak.new doc
        expected_doc << SSML::Voice.new(doc, :gender => :male, :name => 'fred')
        SSML.draw { voice :gender => :male, :name => 'fred' }.should == expected_doc
      end

      it "should allow nested block return values" do
        expected_doc = SSML::Speak.new doc
        expected_doc << SSML::Voice.new(doc, :gender => :male, :name => 'fred', :content => "Hi, I'm Fred.")

        doc = RubySpeech::SSML.draw do
          voice :gender => :male, :name => 'fred' do
            "Hi, I'm Fred."
          end
        end
        doc.should == expected_doc
      end

      it "should allow nested SSML elements" do
        drawn_doc = RubySpeech::SSML.draw do
          voice :gender => :male, :name => 'fred' do
            string "Hi, I'm Fred. The time is currently "
            say_as :interpret_as => 'date', :format => 'dmy' do
              "01/02/1960"
            end
          end
        end

        voice = SSML::Voice.new(doc, :gender => :male, :name => 'fred', :content => "Hi, I'm Fred. The time is currently ")
        voice << SSML::SayAs.new(doc, :interpret_as => 'date', :format => 'dmy', :content => "01/02/1960")
        expected_doc = SSML::Speak.new doc
        expected_doc << voice
        drawn_doc.should == expected_doc
      end

      it "should allow accessing methods defined outside the block" do
        def foo
          'bar'
        end

        expected_doc = SSML::Speak.new doc, :content => foo
        SSML.draw { string foo }.should == expected_doc
      end

      describe 'cloning' do
        context 'SSML documents' do
          let :original do
            RubySpeech::SSML.draw do
              string "Hi, I'm Fred."
            end
          end

          subject { original.clone }

          it 'should match the contents of the original document' do
            subject.to_s.should == original.to_s
          end

          it 'should match the class of the original document' do
            subject.class.should == original.class
          end

          it 'should be equal to the original document' do
            subject.should == original
          end
        end
      end

      describe "embedding" do
        it "SSML documents" do
          doc1 = RubySpeech::SSML.draw do
            string "Hi, I'm Fred. The time is currently "
            say_as :interpret_as => 'date', :format => 'dmy' do
              "01/02/1960"
            end
          end

          doc2 = RubySpeech::SSML.draw do
            voice :gender => :male, :name => 'fred' do
              embed doc1
            end
          end

          expected_doc = RubySpeech::SSML.draw do
            voice :gender => :male, :name => 'fred' do
              string "Hi, I'm Fred. The time is currently "
              say_as :interpret_as => 'date', :format => 'dmy' do
                "01/02/1960"
              end
            end
          end

          doc2.should == expected_doc
        end

        it "SSML elements" do
          element = SSML::Emphasis.new(doc, :content => "HELLO?")

          doc = RubySpeech::SSML.draw do
            voice :gender => :male, :name => 'fred' do
              embed element
            end
          end

          expected_doc = RubySpeech::SSML.draw do
            voice :gender => :male, :name => 'fred' do
              emphasis do
                "HELLO?"
              end
            end
          end

          doc.should == expected_doc
        end

        it "strings" do
          string = "How now, brown cow?"

          doc = RubySpeech::SSML.draw do
            voice :gender => :male, :name => 'fred' do
              embed string
            end
          end

          expected_doc = RubySpeech::SSML.draw do
            voice :gender => :male, :name => 'fred' do
              string "How now, brown cow?"
            end
          end

          doc.should == expected_doc
        end
      end

      it "should properly escape string input" do
        drawn_doc = RubySpeech::SSML.draw do
          voice { string "I <3 nachos." }
          voice { "I <3 nachos." }
        end
        expected_doc = SSML::Speak.new doc
        2.times do
          expected_doc << SSML::Voice.new(doc, :native_content => "I <3 nachos.")
        end
        drawn_doc.should == expected_doc
      end

      it "should allow all permutations of possible nested SSML elements" do
        drawn_doc = RubySpeech::SSML.draw do
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
        expected_doc = SSML::Speak.new(doc, :content => "Hello world.")
        expected_doc << SSML::Break.new(doc)
        audio = SSML::Audio.new(doc, :src => "hello", :content => "HELLO?")
        audio << SSML::Break.new(doc)
        audio << SSML::Audio.new(doc, :src => "hello")
        audio << SSML::Emphasis.new(doc)
        audio << SSML::Prosody.new(doc)
        audio << SSML::SayAs.new(doc, :interpret_as => 'date')
        audio << SSML::Voice.new(doc)
        expected_doc << audio
        emphasis = SSML::Emphasis.new(doc, :content => "HELLO?")
        emphasis << SSML::Break.new(doc)
        emphasis << SSML::Audio.new(doc, :src => "hello")
        emphasis << SSML::Emphasis.new(doc)
        emphasis << SSML::Prosody.new(doc)
        emphasis << SSML::SayAs.new(doc, :interpret_as => 'date')
        emphasis << SSML::Voice.new(doc)
        expected_doc << emphasis
        prosody = SSML::Prosody.new(doc, :rate => :slow, :content => "H...E...L...L...O?")
        prosody << SSML::Break.new(doc)
        prosody << SSML::Audio.new(doc, :src => "hello")
        prosody << SSML::Emphasis.new(doc)
        prosody << SSML::Prosody.new(doc)
        prosody << SSML::SayAs.new(doc, :interpret_as => 'date')
        prosody << SSML::Voice.new(doc)
        expected_doc << prosody
        expected_doc << SSML::SayAs.new(doc, :interpret_as => 'date', :format => 'dmy', :content => "01/02/1960")
        voice = SSML::Voice.new(doc, :gender => :male, :name => 'fred', :content => "Hi, I'm Fred. The time is currently ")
        voice << SSML::SayAs.new(doc, :interpret_as => 'date', :format => 'dmy', :content => "01/02/1960")
        voice << SSML::Break.new(doc)
        voice << SSML::Audio.new(doc, :src => "hello")
        voice << SSML::Emphasis.new(doc, :content => "I'm so old")
        voice << SSML::Prosody.new(doc, :rate => :fast, :content => "And yet so spritely!")
        voice << SSML::Voice.new(doc, :age => 12, :content => "And I'm young Fred")
        expected_doc << voice
        drawn_doc.should == expected_doc
      end
    end

    describe "importing nested tags" do
      let(:doc) { Nokogiri::XML::Document.new }
      let(:say_as) { SSML::SayAs.new doc, :interpret_as => 'date', :format => 'dmy', :content => "01/02/1960" }
      let(:string) { "Hi, I'm Fred. The time is currently " }
      let :voice do
        SSML::Voice.new(doc, :gender => :male, :name => 'fred', :content => string).tap do |voice|
          voice << say_as
        end
      end

      let :document do
        SSML::Speak.new(doc).tap { |doc| doc << voice }.to_s
      end

      let(:import) { SSML.import document }

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
