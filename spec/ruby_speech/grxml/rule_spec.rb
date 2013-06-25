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
        Element.class_from_registration(:rule).should == Rule
      end

      describe "from a document" do
        let(:document) { '<rule id="one" scope="public"> <item /> </rule>' }

        subject { Element.import document }

        it { should be_instance_of Rule }

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
          lambda { subject.scope = :public }.should_not raise_error
          lambda { subject.scope = :private }.should_not raise_error
        end

        it "with an invalid scope" do
          lambda { subject.scope = :something }.should raise_error(ArgumentError, "A Rule's scope can only be 'public' or 'private'")
        end
      end

      describe "comparing objects" do
        it "should be equal if the content, language, id, and scope are the same" do
          Rule.new(doc, :language => 'jp', :id => :main, :scope => :public, :content => "hello").should == Rule.new(doc, :language => 'jp', :id => :main, :scope => :public, :content => "hello")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Rule.new(doc, :content => "Hello").should_not == Rule.new(doc, :content => "Hello there")
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            Rule.new(doc, :language => "jp").should_not == Rule.new(doc, :language => "esperanto")
          end
        end

        describe "when the id is different" do
          it "should not be equal" do
            Rule.new(doc, :id => :main).should_not == Rule.new(doc, :id => :dtmf)
          end
        end

        describe "when the scope is different" do
          it "should not be equal" do
            Rule.new(doc, :scope => :public).should_not == Rule.new(doc, :scope => :private)
          end
        end
      end

      describe "<<" do
        it "should accept String" do
          lambda { subject << 'anything' }.should_not raise_error
        end

        it "should accept OneOf" do
          lambda { subject << OneOf.new(doc) }.should_not raise_error
        end

        it "should accept Item" do
          lambda { subject << Item.new(doc) }.should_not raise_error
        end

        it "should accept Ruleref" do
          lambda { subject << Ruleref.new(doc) }.should_not raise_error
        end

        it "should accept Tag" do
          lambda { subject << Tag.new(doc) }.should_not raise_error
        end

        it "should accept Token" do
          lambda { subject << Token.new(doc) }.should_not raise_error
        end
      end

      it "should raise ArgumentError with any other scope" do
        lambda { Rule.new doc, :id => 'one', :scope => 'invalid_scope' }.should raise_error(ArgumentError, "A Rule's scope can only be 'public' or 'private'")
      end
    end # Rule
  end # GRXML
end # RubySpeech
