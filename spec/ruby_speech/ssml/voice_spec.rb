require 'spec_helper'

module RubySpeech
  module SSML
    describe Voice do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:node_name) { should == 'voice' }
      its(:name) { should be_nil }

      describe "setting options in initializers" do
        subject { Voice.new doc, :language => 'jp', :gender => :male, :age => 25, :variant => 2, :name => "paul" }

        its(:language)  { should == 'jp' }
        its(:gender)    { should == :male }
        its(:age)       { should == 25 }
        its(:variant)   { should == 2 }
        its(:name)      { should == 'paul' }
      end

      it 'registers itself' do
        Element.class_from_registration(:voice).should == Voice
      end

      describe "from a document" do
        let(:document) { '<voice xml:lang="jp" gender="male" age="25" variant="2" name="paul"/>' }

        subject { Element.import document }

        it { should be_instance_of Voice }

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

      describe "comparing objects" do
        it "should be equal if the content, language, gender, age, variant, name are the same" do
          Voice.new(doc, :language => 'jp', :gender => :male, :age => 25, :variant => 2, :name => "paul", :content => "hello").should == Voice.new(doc, :language => 'jp', :gender => :male, :age => 25, :variant => 2, :name => "paul", :content => "hello")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Voice.new(doc, :content => "Hello").should_not == Voice.new(doc, :content => "Hello there")
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            Voice.new(doc, :language => "Hello").should_not == Voice.new(doc, :language => "Hello there")
          end
        end

        describe "when the gender is different" do
          it "should not be equal" do
            Voice.new(doc, :gender => :male).should_not == Voice.new(doc, :gender => :female)
          end
        end

        describe "when the age is different" do
          it "should not be equal" do
            Voice.new(doc, :age => 20).should_not == Voice.new(doc, :age => 30)
          end
        end

        describe "when the variant is different" do
          it "should not be equal" do
            Voice.new(doc, :variant => 1).should_not == Voice.new(doc, :variant => 2)
          end
        end

        describe "when the name is different" do
          it "should not be equal" do
            Voice.new(doc, :name => "Hello").should_not == Voice.new(doc, :name => "Hello there")
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

        it "should accept SayAs" do
          lambda { subject << SayAs.new(doc, :interpret_as => :foo) }.should_not raise_error
        end

        it "should accept Sub" do
          lambda { subject << Sub.new(doc) }.should_not raise_error
        end

        it "should accept S" do
          lambda { subject << S.new(doc) }.should_not raise_error
        end

        it "should accept Voice" do
          lambda { subject << Voice.new(doc) }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << 1 }.should raise_error(InvalidChildError, "A Voice can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
        end
      end
    end # Voice
  end # SSML
end # RubySpeech
