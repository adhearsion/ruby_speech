require 'spec_helper'

module RubySpeech
  module GRXML
    describe Grammar do
      let(:doc) { Nokogiri::XML::Document.new }

      subject { described_class.new doc }

      it { is_expected.to be_a_valid_grxml_document }

      its(:name)      { should == 'grammar' }
      its(:language)  { should == 'en-US' }

      describe "setting options in initializers" do
        subject { Grammar.new doc, :language => 'jp', :base_uri => 'blah', :root => "main_rule", :tag_format => "semantics/1.0" }

        its(:language)    { should == 'jp' }
        its(:base_uri)    { should == 'blah' }
        its(:root)        { should == 'main_rule' }
        its(:tag_format)  { should == 'semantics/1.0' }
      end

      describe "setting dtmf mode" do
        subject       { Grammar.new doc, :mode => 'dtmf' }
        its(:mode)    { should == :dtmf }
        its(:dtmf?)   { should be true }
        its(:voice?)  { should be false }
      end

      describe "setting voice mode" do
        subject       { Grammar.new doc, :mode => 'voice' }
        its(:mode)    { should == :voice }
        its(:voice?)  { should be true }
        its(:dtmf?)   { should be false }
      end

      it 'registers itself' do
        expect(Element.class_from_registration(:grammar)).to eq(Grammar)
      end

      describe "from a document" do
        let(:document) { '<grammar mode="dtmf" root="main_rule" version="1.0"  xml:lang="jp" xml:base="blah"
                                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                                 xsi:schemaLocation="http://www.w3.org/2001/06/grammar
                                                     http://www.w3.org/TR/speech-grammar/grammar.xsd"
                                 xmlns="http://www.w3.org/2001/06/grammar" />' }

        subject { Element.import document }

        it { is_expected.to be_instance_of Grammar }

        its(:language)  { should == 'jp' }
        its(:base_uri)  { should == 'blah' }
        its(:mode)      { should == :dtmf }
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
          expect(Grammar.new(doc, :language => 'en-GB', :base_uri => 'blah', :content => "Hello there")).to eq(Grammar.new(doc, :language => 'en-GB', :base_uri => 'blah', :content => "Hello there"))
        end

        describe "when the content is different" do
          it "should not be equal" do
            expect(Grammar.new(doc, :content => "Hello")).not_to eq(Grammar.new(doc, :content => "Hello there"))
          end
        end

        describe "when the language is different" do
          it "should not be equal" do
            expect(Grammar.new(doc, :language => 'en-US')).not_to eq(Grammar.new(doc, :language => 'en-GB'))
          end
        end

        describe "when the base URI is different" do
          it "should not be equal" do
            expect(Grammar.new(doc, :base_uri => 'foo')).not_to eq(Grammar.new(doc, :base_uri => 'bar'))
          end
        end

        describe "when the children are different" do
          it "should not be equal" do
            g1 = Grammar.new doc
            g1 << Rule.new(doc, :id => 'main1')
            g2 = Grammar.new doc
            g2 << Rule.new(doc, :id => 'main2')

            expect(g1).not_to eq(g2)
          end
        end
      end

      it "should allow creating child GRXML elements" do
        g = Grammar.new doc
        g.rule :id => :main, :scope => 'public'
        expected_g = Grammar.new doc
        expected_g << Rule.new(doc, :id => :main, :scope => 'public')
        expect(g).to eq(expected_g)
      end

      describe "<<" do
        it "should accept Rule" do
          expect { subject << Rule.new(doc) }.not_to raise_error
        end

        it "should accept Tag" do
          expect { subject << Tag.new(doc) }.not_to raise_error
        end

        it "should raise InvalidChildError with non-acceptable objects" do
          expect { subject << 1 }.to raise_error(InvalidChildError, "A Grammar can only accept Rule and Tag as children")
        end
      end

      describe "#to_doc" do
        it "should create an XML document from the grammar" do
          expect(subject.to_doc).to eq(subject.document)
        end
      end

      describe "#tag_format" do
        it "should allow setting tag-format identifier" do
          expect { subject.tag_format = "semantics/1.0" }.not_to raise_error
        end
      end

      describe "concat" do
        it "should allow concatenation" do
          grammar1 = Grammar.new doc
          grammar1 << Rule.new(doc, :id => 'frank', :scope => 'public', :content => "Hi Frank")
          grammar2 = Grammar.new doc
          grammar2 << Rule.new(doc, :id => 'millie', :scope => 'public', :content => "Hi Millie")

          grammar1_string = grammar1.to_s
          grammar2_string = grammar2.to_s

          expected_concat = Grammar.new doc
          expected_concat << Rule.new(doc, :id => 'frank', :scope => 'public', :content => "Hi Frank")
          expected_concat << Rule.new(doc, :id => 'millie', :scope => 'public', :content => "Hi Millie")

          concat = grammar1 + grammar2
          expect(grammar1.to_s).to eq(grammar1_string)
          expect(grammar2.to_s).to eq(grammar2_string)
          expect(concat).to eq(expected_concat)
          expect(concat.document.root).to eq(concat)
          expect(concat.to_s).not_to include('default')
        end
      end

      it "should allow finding its root rule" do
        grammar = GRXML::Grammar.new doc, :root => 'foo'
        bar = GRXML::Rule.new doc, :id => 'bar'
        grammar << bar
        foo = GRXML::Rule.new doc, :id => 'foo'
        grammar << foo

        expect(grammar.root_rule).to eq(foo)
      end

      describe "inlining rule references" do
        let :grammar do
          GRXML.draw :root => 'pin', :mode => :dtmf do
            rule :id => 'digits' do
              one_of do
                0.upto(9) { |d| item { d.to_s } }
              end
            end

            rule :id => 'pin', :scope => 'public' do
              one_of do
                item do
                  item :repeat => '4' do
                    ruleref :uri => '#digits'
                  end
                  item { '*' }
                  item { ruleref uri: '#digits' }
                  "#"
                end
                item do
                  "* 9"
                end
              end
            end
          end
        end

        let :inline_grammar do
          GRXML.draw :root => 'pin', :mode => :dtmf do
            rule :id => 'pin', :scope => 'public' do
              one_of do
                item do
                  item :repeat => '4' do
                    one_of do
                      0.upto(9) { |d| item { d.to_s } }
                    end
                  end
                  item { '*' }
                  item do
                    one_of do
                      0.upto(9) { |d| item { d.to_s } }
                    end
                  end
                  "#"
                end
                item do
                  "* 9"
                end
              end
            end
          end
        end

        it "should be possible in a non-destructive manner" do
          expect(grammar.inline).to eq(inline_grammar)
          expect(grammar).not_to eq(inline_grammar)
        end

        it "should be possible in a destructive manner" do
          expect(grammar.inline!).to eq(inline_grammar)
          expect(grammar).to eq(inline_grammar)
        end

        context 'nested' do
          let :expected_doc do
            RubySpeech::GRXML.draw mode: :dtmf, root: 'main' do
              rule id: :main, scope: 'public' do
                string "How about an oatmeal cookie?  You'll feel better."
              end
            end
          end

          context '1 level deep' do
            subject do
              RubySpeech::GRXML.draw mode: :dtmf, root: 'main' do
                rule id: :main, scope: 'public' do
                  ruleref uri: '#rabbit_hole2'
                end
                rule id: 'rabbit_hole2' do
                  string "How about an oatmeal cookie?  You'll feel better."
                end
              end.inline
            end

            it { is_expected.to eq expected_doc }
          end

          context '2 levels deep' do
            subject do
              RubySpeech::GRXML.draw mode: :dtmf, root: 'main' do
                rule id: :main, scope: 'public' do
                  ruleref uri: '#rabbit_hole2'
                end
                rule id: 'rabbit_hole2' do
                  ruleref uri: '#rabbit_hole3'
                end
                rule id: 'rabbit_hole3' do
                  string "How about an oatmeal cookie?  You'll feel better."
                end
              end.inline
            end

            it { is_expected.to eq expected_doc }
          end

          context '3 levels deep' do
            subject do
              RubySpeech::GRXML.draw mode: :dtmf, root: 'main' do
                rule id: :main, scope: 'public' do
                  ruleref uri: '#rabbit_hole2'
                end
                rule id: 'rabbit_hole2' do
                  ruleref uri: '#rabbit_hole3'
                end
                rule id: 'rabbit_hole3' do
                  ruleref uri: '#rabbit_hole4'
                end
                rule id: 'rabbit_hole4' do
                  string "How about an oatmeal cookie?  You'll feel better."
                end
              end.inline
            end

            it { is_expected.to eq expected_doc }
          end

          context 'in a self-referencial infinite loop' do
            subject do
              RubySpeech::GRXML.draw mode: :dtmf, root: 'main' do
                rule id: :main, scope: 'public' do
                  ruleref uri: '#paradox'
                end
                rule id: 'paradox' do
                  ruleref uri: '#paradox'
                end
              end.inline
            end

            it 'should raise an Exception' do
              expect { subject }
                .to raise_error RubySpeech::GRXML::ReferentialLoopError
            end
          end

          context 'in a cross-referencial infinite loop' do
            subject do
              RubySpeech::GRXML.draw mode: :dtmf, root: 'main' do
                rule id: :main, scope: 'public' do
                  ruleref uri: '#007'
                end
                rule id: '007' do
                  one_of do
                    item do
                      ruleref uri: '#bond'
                    end
                  end
                end
                rule id: 'bond' do
                  one_of do
                    item do
                      ruleref uri: '#james_bond'
                    end
                  end
                end
                rule id: 'james_bond' do
                  one_of do
                    item do
                      ruleref uri: '#007'
                    end
                  end
                end
              end.inline
            end

            it 'should raise an Exception' do
              expect { subject }
                .to raise_error RubySpeech::GRXML::ReferentialLoopError
            end
          end

          context 'with an invalid-reference' do
            subject do
              RubySpeech::GRXML.draw mode: :dtmf, root: 'main' do
                rule id: :main, scope: 'public' do
                  ruleref uri: '#lost'
                end
              end.inline
            end

            it 'should raise a descriptive exception' do
              expect { subject }
                .to raise_error RubySpeech::GRXML::MissingReferenceError,
                                "Ruleref '#lost' is referenced but not defined"
            end
          end
        end
      end

      describe "#tokenize!" do
        def single_rule_grammar(content = [])
          GRXML.draw :root => 'm', :mode => :speech do
            rule :id => 'm' do
              Array(content).each { |e| embed e }
            end
          end
        end

        subject { single_rule_grammar content }

        let(:tokenized_version) do
          expected_tokens = Array(tokens).map do |s|
            Token.new(doc).tap { |t| t << s }
          end
          single_rule_grammar expected_tokens
        end

        before { subject.tokenize! }

        context "with a single unquoted token" do
          let(:content) { 'hello' }
          let(:tokens)  { 'hello' }

          it "should tokenize correctly" do
            is_expected.to eq(tokenized_version)
          end
        end

        context "with a single unquoted token (non-alphabetic)" do
          let(:content) { '2' }
          let(:tokens)  { ['2'] }

          it "should tokenize correctly" do
            is_expected.to eq(tokenized_version)
          end
        end

        context "with a single quoted token (including whitespace)" do
          let(:content) { '"San Francisco"' }
          let(:tokens)  { ['San Francisco'] }

          it "should tokenize correctly" do
            is_expected.to eq(tokenized_version)
          end
        end

        context "with a single quoted token (no whitespace)" do
          let(:content) { '"hello"' }
          let(:tokens)  { ['hello'] }

          it "should tokenize correctly" do
            is_expected.to eq(tokenized_version)
          end
        end

        context "with two tokens delimited by white space" do
          let(:content) { 'bon voyage' }
          let(:tokens)  { ['bon', 'voyage'] }

          it "should tokenize correctly" do
            is_expected.to eq(tokenized_version)
          end
        end

        context "with four tokens delimited by white space" do
          let(:content) { 'this is a test' }
          let(:tokens)  { ['this', 'is', 'a', 'test'] }

          it "should tokenize correctly" do
            is_expected.to eq(tokenized_version)
          end
        end

        context "with a single XML token" do
          let(:content) { [Token.new(doc).tap { |t| t << 'San Francisco' }] }
          let(:tokens)  { ['San Francisco'] }

          it "should tokenize correctly" do
            is_expected.to eq(tokenized_version)
          end
        end

        context "with a mixture of token types" do
          let(:content) do
            [
              'Welcome to "San Francisco"',
              Token.new(doc).tap { |t| t << 'Have Fun!' }
            ]
          end

          let(:tokens) { ['Welcome', 'to', 'San Francisco', 'Have Fun!'] }

          it "should tokenize correctly" do
            is_expected.to eq(tokenized_version)
          end
        end
      end

      describe "#normalize_whitespace" do
        it "should normalize whitespace in all of the tokens contained within it" do
          grammar = GRXML.draw do
            rule do
              token { ' Welcome to ' }
              token { ' San  Francisco ' }
            end
          end

          normalized_grammar = GRXML.draw do
            rule do
              token { 'Welcome to' }
              token { 'San Francisco' }
            end
          end

          expect(grammar).not_to eq(normalized_grammar)
          grammar.normalize_whitespace
          expect(grammar).to eq(normalized_grammar)
        end
      end
    end # Grammar
  end # GRXML
end # RubySpeech
