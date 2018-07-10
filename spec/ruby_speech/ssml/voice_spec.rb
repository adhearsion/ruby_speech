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
        expect(Element.class_from_registration(:voice)).to eq(Voice)
      end

      describe "from a document" do
        let(:document) { '<voice xml:lang="jp" gender="male" age="25" variant="2" name="paul"/>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Voice }

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
          expect { subject.gender = :male }.not_to raise_error
          expect { subject.gender = :female }.not_to raise_error
          expect { subject.gender = :neutral }.not_to raise_error
        end

        it "with an invalid gender" do
          expect { subject.gender = :something }.to raise_error(ArgumentError, "You must specify a valid gender (:male, :female, :neutral)")
        end
      end

      describe "#age" do
        before { subject.age = 12 }

        its(:age) { should == 12 }

        it "with an integer of 0" do
          expect { subject.age = 0 }.not_to raise_error
        end

        it "with an integer less than 0" do
          expect { subject.age = -1 }.to raise_error(ArgumentError, "You must specify a valid age (non-negative integer)")
        end

        it "with something other than an integer" do
          expect { subject.age = "bah" }.to raise_error(ArgumentError, "You must specify a valid age (non-negative integer)")
        end
      end

      describe "#variant" do
        before { subject.variant = 12 }

        its(:variant) { should == 12 }

        it "with an integer less than 1" do
          expect { subject.variant = 0 }.to raise_error(ArgumentError, "You must specify a valid variant (positive integer)")
        end

        it "with something other than an integer" do
          expect { subject.variant = "bah" }.to raise_error(ArgumentError, "You must specify a valid variant (positive integer)")
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
          expect(Voice.new(doc, :language => 'jp', :gender => :male, :age => 25, :variant => 2, :name => "paul", :content => "hello")).to eq(Voice.new(doc, :language => 'jp', :gender => :male, :age => 25, :variant => 2, :name => "paul", :content => "hello"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Voice.new(doc, :content => "Hello")).not_to eq(Voice.new(doc, :content => "Hello there"))
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            expect(Voice.new(doc, :language => "Hello")).not_to eq(Voice.new(doc, :language => "Hello there"))
          end
        end

        describe "when the gender is different" do
          it "should not be equal" do
            expect(Voice.new(doc, :gender => :male)).not_to eq(Voice.new(doc, :gender => :female))
          end
        end

        describe "when the age is different" do
          it "should not be equal" do
            expect(Voice.new(doc, :age => 20)).not_to eq(Voice.new(doc, :age => 30))
          end
        end

        describe "when the variant is different" do
          it "should not be equal" do
            expect(Voice.new(doc, :variant => 1)).not_to eq(Voice.new(doc, :variant => 2))
          end
        end

        describe "when the name is different" do
          it "should not be equal" do
            expect(Voice.new(doc, :name => "Hello")).not_to eq(Voice.new(doc, :name => "Hello there"))
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
          expect { subject << 1 }.to raise_error(InvalidChildError, "A Voice can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
        end
      end
    end # Voice
  end # SSML
end # RubySpeech
