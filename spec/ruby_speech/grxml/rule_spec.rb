require 'spec_helper'

module RubySpeech
  module GRXML
    describe Rule do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { Rule.new doc, :id => 'one', :scope => 'public' }

      its(:name) { should == 'rule' }

      its(:id)    { should == :one }
      its(:scope) { should == :public }

      it 'registers itself' do
        expect(Element.class_from_registration(:rule)).to eq(Rule)
      end

      describe "from a document" do
        let(:document) { '<rule id="one" scope="public"> <item /> </rule>' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Rule }

        its(:id)    { should == :one }
        its(:scope) { should == :public }
      end

      describe "#language" do
        before { subject.language = 'jp' }

        its(:language) { should == 'jp' }
      end

      describe "#id" do
        before { subject.id = :main }

        its(:id) { should == :main }

        context "without an id" do
          before { subject.id = nil }
          pending
        end

        context "with a non-unique id" do
          pending 'this should probably go into the grammar spec'
        end
      end

      describe "#scope" do
        before { subject.scope = :public }

        its(:scope) { should == :public }

        it "with a valid scope" do
          expect { subject.scope = :public }.not_to raise_error
          expect { subject.scope = :private }.not_to raise_error
        end

        it "with an invalid scope" do
          expect { subject.scope = :something }.to raise_error(ArgumentError, "A Rule's scope can only be 'public' or 'private'")
        end
      end

      describe "comparing objects" do
        it "should be equal if the content, language, id, and scope are the same" do
          expect(Rule.new(doc, :language => 'jp', :id => :main, :scope => :public, :content => "hello")).to eq(Rule.new(doc, :language => 'jp', :id => :main, :scope => :public, :content => "hello"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Rule.new(doc, :content => "Hello")).not_to eq(Rule.new(doc, :content => "Hello there"))
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            expect(Rule.new(doc, :language => "jp")).not_to eq(Rule.new(doc, :language => "esperanto"))
          end
        end

        describe "when the id is different" do
          it "should not be equal" do
            expect(Rule.new(doc, :id => :main)).not_to eq(Rule.new(doc, :id => :dtmf))
          end
        end

        describe "when the scope is different" do
          it "should not be equal" do
            expect(Rule.new(doc, :scope => :public)).not_to eq(Rule.new(doc, :scope => :private))
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          expect { subject << 'anything' }.not_to raise_error
        end

        it "should accept OneOf" do
          expect { subject << OneOf.new(doc) }.not_to raise_error
        end

        it "should accept Item" do
          expect { subject << Item.new(doc) }.not_to raise_error
        end

        it "should accept Ruleref" do
          expect { subject << Ruleref.new(doc) }.not_to raise_error
        end

        it "should accept Tag" do
          expect { subject << Tag.new(doc) }.not_to raise_error
        end

        it "should accept Token" do
          expect { subject << Token.new(doc) }.not_to raise_error
        end
      end

      it "should raise ArgumentError with any other scope" do
        expect { Rule.new doc, :id => 'one', :scope => 'invalid_scope' }.to raise_error(ArgumentError, "A Rule's scope can only be 'public' or 'private'")
      end
    end # Rule
  end # GRXML
end # RubySpeech
