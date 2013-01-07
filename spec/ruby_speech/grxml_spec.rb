require 'spec_helper'

module RubySpeech
  describe GRXML do
    describe "#draw" do
      it "should create a GRXML document" do
        GRXML.draw.should == GRXML::Grammar.new
      end

      context "with a root rule name specified but not found" do
        it "should raise an error" do
          lambda do
            GRXML.draw :root => 'foo' do
              rule :id => 'bar' do
                '6'
              end
            end
          end.should raise_error(InvalidChildError, "A GRXML document must have a rule matching the root rule name")
        end
      end

      # TODO: Maybe GRXML#draw should create a Rule to pass the string
      describe "when the return value of the block is a string" do
        it "should be inserted into the document" do
          lambda { GRXML.draw { "Hello Fred" }}.should raise_error(InvalidChildError, "A Grammar can only accept Rule and Tag as children")
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

      it "should allow accessing methods defined outside the block" do
        def foo
          'bar'
        end

        doc = GRXML.draw do
          rule :id => foo
        end

        expected_doc = GRXML::Grammar.new
        rule = GRXML::Rule.new(:id => foo)
        expected_doc << rule
        doc.should == expected_doc
      end

      it "should raise error if given an empty rule" do
        pending 'Reject empty rules -- http://www.w3.org/TR/2002/CR-speech-grammar-20020626/#S3.1 http://www.w3.org/Voice/2003/srgs-ir/test/rule-no-empty.grxml'
        lambda { GRXML.draw { rule :id => 'main' }}.should raise_error
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

      # TODO: maybe turn a rule embedded in anthoer rule into a ruleref??
      describe "embedding" do
        context "GRXML documents" do
          let :doc1 do
            RubySpeech::GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => :digits do
                one_of do
                  item { "1" }
                  item { "2" }
                end
              end
            end
          end

          let :doc2 do
            doc = doc1
            RubySpeech::GRXML.draw :mode => :dtmf do
              embed doc
              rule :id => :main do
                "Hello Fred"
              end
            end
          end

          let :expected_doc do
            RubySpeech::GRXML.draw :mode => :dtmf do
              rule :id => :digits do
                one_of do
                 item :content => "1"
                 item :content => "2"
                end
              end
              rule :id => :main, :content => 'Hello Fred'
            end
          end

          it "should embed the document" do
            doc2.should == expected_doc
          end

          context "of different modes (dtmf in voice or vice-versa)" do
            let :voice_doc do
              GRXML.draw :mode => :voice do
                embed dtmf_doc
              end
            end

            let :dtmf_doc do
              GRXML.draw :mode => :dtmf do
                rule do
                  '6'
                end
              end
            end

            it "should raise an exception" do
              lambda { voice_doc }.should raise_error(InvalidChildError, "Embedded grammars must have the same mode")
            end
          end
        end

        it "GRXML elements" do
          element = GRXML::Item.new :content => "HELLO?"

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
          expected_doc << GRXML::Rule.new(:native_content => "I <3 nachos.")
        end
        doc.should == expected_doc
      end

      # TODO: verfify rule is in document if named in a ruleref
      # TODO: ruleref must have named rule id

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
            token { "test token" }
            tag { }
            item { "" }
            one_of { item { "single item" } }
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
        rule << GRXML::Token.new(:content => "test token")
        rule << GRXML::Tag.new
        rule << GRXML::Item.new
        oneof = GRXML::OneOf.new
        oneof << GRXML::Item.new(:content => "single item")
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

        let(:import) { GRXML.import document }

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

      it "should allow finding direct children of a particular type, matching certain attributes" do
        item = GRXML::Item.new
        item1 = GRXML::Item.new :weight => 0.5
        item11 = GRXML::Item.new :weight => 0.5
        item1 << item11
        item << item1
        item2 = GRXML::Item.new :weight => 0.7
        item << item2
        tag = GRXML::Tag.new
        item << tag

        item.children(:item, :weight => 0.5).should == [item1]
      end

      it "should be able to traverse up the tree" do
        grammar = GRXML.draw do
          rule :id => 'one' do
            item do
              'foobar'
            end
          end
        end

        rule = grammar.children.first
        rule.parent.should == grammar

        item = rule.children.first
        item.parent.should == rule

        text = item.nokogiri_children.first
        text.parent.should == item
      end
    end # draw

    describe "manually created documents" do
      it "should be able to traverse up the tree" do
        grammar = GRXML::Grammar.new
        rule    = GRXML::Rule.new :id => 'one'
        item    = GRXML::Item.new
        text    = Nokogiri::XML::Text.new 'foobar', grammar.document
        item    << text
        rule    << item
        grammar << rule

        text.parent.should == item
        item.parent.should == rule
        rule.parent.should == grammar
      end
    end
  end # GRXML
end # RubySpeech
