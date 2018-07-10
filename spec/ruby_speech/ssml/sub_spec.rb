require 'spec_helper'

module RubySpeech
  module SSML
    describe Sub do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      its(:name) { should == 'sub' }

      describe "setting options in initializers" do
        subject { Sub.new doc, :alias => 'foo' }

        its(:alias) { should == 'foo' }
      end

      it 'registers itself' do
        expect(Element.class_from_registration(:sub)).to eq(Sub)
      end

      describe "from a document" do
        let(:document) { '<sub alias="foo"/>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Sub }

        its(:alias) { should == 'foo' }
      end

      describe "comparing objects" do
        it "should be equal if the content and alias are the same" do
          expect(Sub.new(doc, :alias => 'jp', :content => "Hello there")).to eq(Sub.new(doc, :alias => 'jp', :content => "Hello there"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Sub.new(doc, :content => "Hello")).not_to eq(Sub.new(doc, :content => "Hello there"))
          end
        end

        describe "when the alias is different" do
          it "should not be equal" do
            expect(Sub.new(doc, :alias => 'jp')).not_to eq(Sub.new(doc, :alias => 'en'))
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          expect { subject << 'anything' }.not_to raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          expect { subject << Voice.new(doc) }.to raise_error(InvalidChildError, "A Sub can only accept Strings as children")
        end
      end
    end # Desc
  end # SSML
end # RubySpeech
