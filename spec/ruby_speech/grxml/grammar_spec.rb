require 'spec_helper'

module RubySpeech
  module GRXML
    describe Grammar do
      it { should be_a_valid_grxml_document }

      its(:name)      { should == 'grammar' }
      its(:language)  { should == 'en-US' }

      describe "setting options in initializers" do
        subject { Grammar.new :language => 'jp', :base_uri => 'blah', :root => "main_rule" }

        its(:language)  { should == 'jp' }
        its(:base_uri)  { should == 'blah' }
        its(:root)      { should == 'main_rule' }
      end

      describe "setting dtmf mode" do
        subject     { Grammar.new :mode => 'dtmf' }
        its(:mode)  { should == 'dtmf' }
      end

      describe "setting voice mode" do
        subject     { Grammar.new :mode => 'voice' }
        its(:mode)  { should == 'voice' }
      end

      it 'registers itself' do
        Element.class_from_registration(:grammar).should == Grammar
      end

      describe "from a document" do
        let(:document) { '<grammar mode="dtmf" root="main_rule" version="1.0"  xml:lang="jp" xml:base="blah"
                                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                                 xsi:schemaLocation="http://www.w3.org/2001/06/grammar
                                                     http://www.w3.org/TR/speech-grammar/grammar.xsd"
                                 xmlns="http://www.w3.org/2001/06/grammar" />' }

        subject { Element.import parse_xml(document).root }

        it { should be_instance_of Grammar }

        its(:language)  { pending; should == 'jp' }
        its(:base_uri)  { should == 'blah' }
        its(:mode)      { should == 'dtmf' }
        its(:root)      { should == 'main_rule' }
      end

      describe "#language" do
        before { subject.language = 'jp' }

        its(:language) { should == 'jp' }
      end

      describe "#base_uri" do
        before { subject.base_uri = 'blah' }

        its(:base_uri) { should == 'blah' }
      end

      describe "comparing objects" do
        it "should be equal if the content, language and base uri are the same" do
          Grammar.new(:language => 'en-GB', :base_uri => 'blah', :content => "Hello there").should == Grammar.new(:language => 'en-GB', :base_uri => 'blah', :content => "Hello there")
        end

        describe "when the content is different" do
          it "should not be equal" do
            Grammar.new(:content => "Hello").should_not == Grammar.new(:content => "Hello there")
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            Grammar.new(:language => 'en-US').should_not == Grammar.new(:language => 'en-GB')
          end
        end

        describe "when the base URI is different" do
          it "should not be equal" do
            Grammar.new(:base_uri => 'foo').should_not == Grammar.new(:base_uri => 'bar')
          end
        end

        describe "when the children are different" do
          it "should not be equal" do
            g1 = Grammar.new
            g1 << Rule.new(:id => 'main1')
            g2 = Grammar.new
            g2 << Rule.new(:id => 'main2')

            g1.should_not == g2
          end
        end
      end

      it "should allow creating child GRXML elements" do
        g = Grammar.new
        g.Rule :id => :main, :scope => 'public'
        expected_g = Grammar.new
        expected_g << Rule.new(:id => :main, :scope => 'public')
        g.should == expected_g
      end

      describe "<<" do
        it "should accept Rule" do
          lambda { subject << Rule.new }.should_not raise_error
        end

        it "should accept Tag" do
          lambda { subject << Tag.new }.should_not raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          lambda { subject << 1 }.should raise_error(InvalidChildError, "A Grammar can only accept Rule and Tag as children")
        end
      end

      describe "#to_doc" do
        let(:expected_doc) do
          Nokogiri::XML::Document.new.tap do |doc|
            doc << Grammar.new
          end
        end

        it "should create an XML document from the grammar" do
          Grammar.new.to_doc.to_s.should == expected_doc.to_s
        end
      end

      describe "concat" do
        it "should allow concatenation" do
          grammar1 = Grammar.new
          grammar1 << Rule.new(:id => 'frank', :scope => 'public', :content => "Hi Frank")
          grammar2 = Grammar.new
          grammar2 << Rule.new(:id => 'millie', :scope => 'public', :content => "Hi Millie")

          expected_concat = Grammar.new
          expected_concat << Rule.new(:id => 'frank', :scope => 'public', :content => "Hi Frank")
          expected_concat << Rule.new(:id => 'millie', :scope => 'public', :content => "Hi Millie")

          concat = (grammar1 + grammar2)
          concat.should == expected_concat
          concat.to_s.should_not include('default')
        end
      end
    end # Grammar
  end # GRXML
end # RubySpeech
