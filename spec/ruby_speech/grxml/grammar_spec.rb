require 'spec_helper'

module RubySpeech
  module GRXML
    describe Grammar do
      it { should be_a_valid_grxml_document }

      its(:name) { should == 'grammar' }
      its(:language) { should == 'en-US' }

      describe "setting options in initializers" do
        subject { Grammar.new :language => 'jp', :base_uri => 'blah', :root => "main_rule" }

        its(:language) { should == 'jp' }
        its(:base_uri) { should == 'blah' }
        its(:root) { should == 'main_rule' }
      end

      describe "setting dtmf mode" do
        subject { Grammar.new :mode => 'dtmf' }
        its(:mode) { should == 'dtmf' }
      end

      describe "setting voice mode" do
        subject { Grammar.new :mode => 'voice' }
        its(:mode) { should == 'voice' }
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

       its(:language) { pending; should == 'jp' }
       its(:base_uri) { should == 'blah' }
       its(:mode) { should == 'dtmf' }
       its(:root) { should == 'main_rule' }
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
#        it "should be equal if the content, language and base uri are the same" do
#          Grammar.new(:language => 'en-GB', :base_uri => 'blah', :content => "Hello there").should == Grammar.new(:language => 'en-GB', :base_uri => 'blah', :content => "Hello there")
#        end
#
#        describe "when the content is different" do
#          it "should not be equal" do
#            Grammar.new(:content => "Hello").should_not == Grammar.new(:content => "Hello there")
#          end
#        end

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
#
#        describe "when the children are different" do
#          it "should not be equal" do
#            s1 = Grammar.new
#            s1 << SayAs.new(:interpret_as => 'date')
#            s2 = Grammar.new
#            s2 << SayAs.new(:interpret_as => 'time')
#
#            s1.should_not == s2
#          end
#        end
      end
#
#      it "should allow creating child GRXML elements" do
#        s = Grammar.new
#        s.voice :gender => :male, :content => 'Hello'
#        expected_s = Grammar.new
#        expected_s << Voice.new(:gender => :male, :content => 'Hello')
#        s.should == expected_s
#      end
#
#      describe "<<" do
#        it "should accept String" do
#          lambda { subject << 'anything' }.should_not raise_error
#        end
#
#        it "should accept Audio" do
#          lambda { subject << Audio.new }.should_not raise_error
#        end
#
#        it "should accept Break" do
#          lambda { subject << Break.new }.should_not raise_error
#        end
#
#        it "should accept Emphasis" do
#          lambda { subject << Emphasis.new }.should_not raise_error
#        end
#
#        it "should accept Mark" do
#          pending
#          lambda { subject << Mark.new }.should_not raise_error
#        end
#
#        it "should accept P" do
#          pending
#          lambda { subject << P.new }.should_not raise_error
#        end
#
#        it "should accept Phoneme" do
#          pending
#          lambda { subject << Phoneme.new }.should_not raise_error
#        end
#
#        it "should accept Prosody" do
#          lambda { subject << Prosody.new }.should_not raise_error
#        end
#
#        it "should accept SayAs" do
#          lambda { subject << SayAs.new(:interpret_as => :foo) }.should_not raise_error
#        end
#
#        it "should accept Sub" do
#          pending
#          lambda { subject << Sub.new }.should_not raise_error
#        end
#
#        it "should accept S" do
#          pending
#          lambda { subject << S.new }.should_not raise_error
#        end
#
#        it "should accept Voice" do
#          lambda { subject << Voice.new }.should_not raise_error
#        end
#
#        it "should raise InvalidChildError with non-acceptable objects" do
#          lambda { subject << 1 }.should raise_error(InvalidChildError, "A Grammar can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children")
#        end
#      end
#
#      describe "#to_doc" do
#        let(:expected_doc) do
#          Nokogiri::XML::Document.new.tap do |doc|
#            doc << Grammar.new
#          end
#        end
#
#        it "should create an XML document from the grammar" do
#          Grammar.new.to_doc.to_s.should == expected_doc.to_s
#        end
#      end
#
#      it "should allow concatenation" do
#        grammar1 = Grammar.new
#        grammar1 << Voice.new(:name => 'frank', :content => "Hi, I'm Frank")
#        grammar2 = Grammar.new
#        grammar2 << "Hello there"
#        grammar2 << Voice.new(:name => 'millie', :content => "Hi, I'm Millie")
#
#        expected_concat = Grammar.new
#        expected_concat << Voice.new(:name => 'frank', :content => "Hi, I'm Frank")
#        expected_concat << "Hello there"
#        expected_concat << Voice.new(:name => 'millie', :content => "Hi, I'm Millie")
#
#        concat = (grammar1 + grammar2)
#        concat.should == expected_concat
#        concat.to_s.should_not include('default')
#      end
    end # Grammar
  end # GRXML
end # RubySpeech
