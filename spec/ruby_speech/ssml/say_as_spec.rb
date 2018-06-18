require 'spec_helper'

module RubySpeech
  module SSML
    describe SayAs do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      subject { SayAs.new doc, :interpret_as => 'one', :format => 'two', :detail => 'three' }

      its(:name) { should == 'say-as' }

      its(:interpret_as) { should == 'one' }
      its(:format)       { should == 'two' }
      its(:detail)       { should == 'three' }

      it 'registers itself' do
        expect(Element.class_from_registration(:'say-as')).to eq(SayAs)
      end

      describe "from a document" do
        let(:document) { '<say-as interpret-as="one" format="two" detail="three"/>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of SayAs }

        its(:interpret_as) { should == 'one' }
        its(:format)       { should == 'two' }
        its(:detail)       { should == 'three' }
      end

      describe "comparing objects" do
        it "should be equal if the content, interpret_as, format, age, variant, name are the same" do
          expect(SayAs.new(doc, :interpret_as => 'jp', :format => 'foo', :detail => 'bar', :content => "hello")).to eq(SayAs.new(doc, :interpret_as => 'jp', :format => 'foo', :detail => 'bar', :content => "hello"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(SayAs.new(doc, :interpret_as => 'jp', :content => "Hello")).not_to eq(SayAs.new(doc, :interpret_as => 'jp', :content => "Hello there"))
          end
        end

        describe "when the interpret_as is different" do
          it "should not be equal" do
            expect(SayAs.new(doc, :interpret_as => "Hello")).not_to eq(SayAs.new(doc, :interpret_as => "Hello there"))
          end
        end

        describe "when the format is different" do
          it "should not be equal" do
            expect(SayAs.new(doc, :interpret_as => 'jp', :format => 'foo')).not_to eq(SayAs.new(doc, :interpret_as => 'jp', :format => 'bar'))
          end
        end

        describe "when the detail is different" do
          it "should not be equal" do
            expect(SayAs.new(doc, :interpret_as => 'jp', :detail => 'foo')).not_to eq(SayAs.new(doc, :interpret_as => 'jp', :detail => 'bar'))
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          expect { subject << 'anything' }.not_to raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          expect { subject << Voice.new(doc) }.to raise_error(InvalidChildError, "A SayAs can only accept Strings as children")
        end
      end
    end # SayAs
  end # SSML
end # RubySpeech
