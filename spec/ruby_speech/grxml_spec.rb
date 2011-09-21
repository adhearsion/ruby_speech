require 'spec_helper'

module RubySpeech
  describe GRXML do
    describe "#draw" do
      it "should create an GRXML document" do
        expected_doc = GRXML::Grammar.new
        GRXML.draw.should == expected_doc
      end

      # TODO: check that a rule exists with the id equal to root if that attribute is set
      it "should have a rule with id equal to the root attribute if set"
      
      # TODO: Maybe GRXML#draw should create a Rule to pass the string
      describe "when the return value of the block is a string" do
        it "should be inserted into the document" do
          lambda{ GRXML.draw { "Hello Fred" }}.should raise_error(InvalidChildError, "A Grammar can only accept Rule and Tag as children")
        end
      end

      it "should allow other GRXML elements to be inserted in the document" do
        doc = GRXML.draw(:mode => :voice, :root => 'main') { rule :id => :main, :content => "Hello Fred" }
  
        expected_doc = GRXML::Grammar.new(:mode => :voice, :root => 'main')
        rule = GRXML::Rule.new(:id => "main")
        rule << "Hello Fred"
        expected_doc << rule
        doc.should == expected_doc
      end

      # TODO: Reject empty rules --  http://www.w3.org/TR/2002/CR-speech-grammar-20020626/#S3.1
      #       http://www.w3.org/Voice/2003/srgs-ir/test/rule-no-empty.grxml
      it "should raise error if given an empty rule" do
        pending;
        lambda{ GRXML.draw { rule :id => 'main' }}.should raise_error
      end

      it "should allow nested block return values" do
        doc = RubySpeech::GRXML.draw do
          rule :scope => 'public', :id => :main do
            "Hello Fred"
          end
        end
        expected_doc = GRXML::Grammar.new
        expected_doc << GRXML::Rule.new(:scope => :public, :id => :main, :content => "Hello Fred")
        doc.should == expected_doc
      end
    
      it "should allow nested GRXML elements" do
        doc = RubySpeech::GRXML.draw do
          rule :id => :main, :scope => 'public' do
            string "Hello Fred. I like ninjas and pirates"
            one_of do
              item :content => "ninja"
              item :content => "pirate"
            end
          end
        end
        rule = GRXML::Rule.new(:id => :main, :scope => 'public', :content => "Hello Fred. I like ninjas and pirates")
        oneof = GRXML::OneOf.new
        oneof << GRXML::Item.new(:content => "ninja")
        oneof << GRXML::Item.new(:content => "pirate")
        rule << oneof
        expected_doc = GRXML::Grammar.new
        expected_doc << rule
        doc.should == expected_doc
      end


      # TODO: don't allow rule to be embedded in another rule
      # TODO: maybe turn a rule embedded in anthoer rule into a ruleref??
      # TODO: Reject embedding (or default to voice) if dtmf and voice documents are merged
      describe "embedding" do
        it "GRXML documents" do
          doc1 = RubySpeech::GRXML.draw(:mode => :dtmf, :root => 'digits') do
            rule :id => :digits do
              one_of do
                item { "1" }
                item { "2" }
              end
            end
          end

          # FIXME: Verify mode of grammar document... it currently takes the last one embedded
          doc2 = RubySpeech::GRXML.draw do
            embed doc1
            rule :id => :main do
              "Hello Fred"
            end
          end

          expected_doc = RubySpeech::GRXML.draw do
            rule :id => :digits do
              one_of do
               item :content => "1"
               item :content => "2"
              end
            end
            rule :id => :main, :content => 'Hello Fred'
          end

          doc2.should == expected_doc
        end

        it "GRXML elements" do
          element = GRXML::Item.new(:content => "HELLO?")

          doc = RubySpeech::GRXML.draw do
            rule :id => :main, :scope => 'public' do
              embed element
            end
          end

          expected_doc = RubySpeech::GRXML.draw do
            rule :id => :main, :scope => 'public' do
              item do
                "HELLO?"
              end
            end
          end

          doc.should == expected_doc
        end

        it "strings" do
          string = "How now, brown cow?"

          doc = RubySpeech::GRXML.draw do
            rule :id => :main, :scope => 'public' do
              embed string
            end
          end

          expected_doc = RubySpeech::GRXML.draw do
            rule :id => :main, :scope => 'public' do
              string "How now, brown cow?"
            end
          end

          doc.should == expected_doc
        end
      end

      it "should properly escape string input" do
        doc = RubySpeech::GRXML.draw do
          rule { string "I <3 nachos." }
          rule { "I <3 nachos." }
          rule { 'I <3 nachos.' }
        end
        expected_doc = GRXML::Grammar.new
        3.times do
          expected_doc << GRXML::Rule.new(:content => "I <3 nachos.")
        end
        doc.should == expected_doc
      end

      # TODO: verfify rule is in document if named in a ruleref
      # TODO: ruleref must have named rule id

      describe "permu"
      it "should allow all permutations of possible nested GRXML elements" do
        doc = RubySpeech::GRXML.draw do
          rule :id => "hello" do
            string "HELLO?"
            item :weight => 2.5
            one_of do
              item { "1" }
              item { "2" }
            end
            ruleref :uri => '#test'
            item { "last" }
          end
          rule :id => "test" do
            string "TESTING"
          end
          rule :id => :hello2 do
            item :weight => 5.5 do
              "hello"
            end
            string "H...E...L...L...O?"
            tag { }
            item { "" }
            one_of { item { "single" } }
          end
        end
        expected_doc = GRXML::Grammar.new
        rule = GRXML::Rule.new(:id => "hello", :content => "HELLO?")
        rule << GRXML::Item.new(:weight => 2.5)
        oneof = GRXML::OneOf.new 
        1.upto(2) { |d| oneof << GRXML::Item.new(:content => d.to_s) }
        rule << oneof
        rule << GRXML::Ruleref.new(:uri => '#test')
        rule << GRXML::Item.new(:content => "last")
        expected_doc << rule

        rule = GRXML::Rule.new(:id => "test", :content => "TESTING")
        expected_doc << rule

        rule = GRXML::Rule.new(:id => "hello2")
        rule << GRXML::Item.new(:weight => 5.5, :content => "hello")
        rule << "H...E...L...L...O?"
        rule << GRXML::Tag.new
        rule << GRXML::Item.new
        oneof = GRXML::OneOf.new
        oneof << GRXML::Item.new(:content => "single")
        rule << oneof
        expected_doc << rule
        doc.should == expected_doc
      end

      describe "importing nested tags" do
        let(:item) { GRXML::Item.new(:weight => 1.5, :content => "Are you a pirate or ninja?") }
        let(:string) { "Hello Fred. I like pirates and ninjas " }
        let :rule do
          GRXML::Rule.new(:id => :main, :scope => 'public', :content => string).tap do |rule|
            rule << item
          end
        end

        let :document do
          GRXML::Grammar.new.tap { |doc| doc << rule }.to_s
        end

        let(:import) { GRXML::Element.import parse_xml(document).root }

        subject { import }

        it "should work" do
          lambda { subject }.should_not raise_error
        end

        it { should be_a GRXML::Grammar }

        its(:children) { should == [rule] }

        describe "rule" do
          subject { import.children.first }
          its(:children) { should == [string,item] }
        end  
      end
    end # draw
  end # GRXML
end # RubySpeech
