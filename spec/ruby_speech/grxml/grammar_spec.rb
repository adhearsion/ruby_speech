require 'spec_helper'

module RubySpeech
  module GRXML
    describe Grammar do
      it { should be_a_valid_grxml_document }

      its(:name)      { should == 'grammar' }
      its(:language)  { should == 'en-US' }

      describe "setting options in initializers" do
        subject { Grammar.new :language => 'jp', :base_uri => 'blah', :root => "main_rule", :tag_format => "semantics/1.0" }

        its(:language)    { should == 'jp' }
        its(:base_uri)    { should == 'blah' }
        its(:root)        { should == 'main_rule' }
        its(:tag_format)  { should == 'semantics/1.0' }
      end

      describe "setting dtmf mode" do
        subject       { Grammar.new :mode => 'dtmf' }
        its(:mode)    { should == :dtmf }
        its(:dtmf?)   { should be true }
        its(:voice?)  { should be false }
      end

      describe "setting voice mode" do
        subject       { Grammar.new :mode => 'voice' }
        its(:mode)    { should == :voice }
        its(:voice?)  { should be true }
        its(:dtmf?)   { should be false }
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

        subject { Element.import document }

        it { should be_instance_of Grammar }

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

      describe "#tag_format" do
        it "should allow setting tag-format identifier" do
          lambda { subject.tag_format = "semantics/1.0" }.should_not raise_error
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

          concat = grammar1 + grammar2
          concat.should == expected_concat
          concat.to_s.should_not include('default')
        end
      end

      it "should allow finding its root rule" do
        grammar = GRXML::Grammar.new :root => 'foo'
        bar = GRXML::Rule.new :id => 'bar'
        grammar << bar
        foo = GRXML::Rule.new :id => 'foo'
        grammar << foo

        grammar.root_rule.should == foo
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
          grammar.inline.should == inline_grammar
          grammar.should_not == inline_grammar
        end

        it "should be possible in a destructive manner" do
          grammar.inline!.should == inline_grammar
          grammar.should == inline_grammar
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
            Token.new.tap { |t| t << s }
          end
          single_rule_grammar expected_tokens
        end

        before { subject.tokenize! }

        context "with a single unquoted token" do
          let(:content) { 'hello' }
          let(:tokens)  { 'hello' }

          it "should tokenize correctly" do
            should == tokenized_version
          end
        end

        context "with a single unquoted token (non-alphabetic)" do
          let(:content) { '2' }
          let(:tokens)  { ['2'] }

          it "should tokenize correctly" do
            should == tokenized_version
          end
        end

        context "with a single quoted token (including whitespace)" do
          let(:content) { '"San Francisco"' }
          let(:tokens)  { ['San Francisco'] }

          it "should tokenize correctly" do
            should == tokenized_version
          end
        end

        context "with a single quoted token (no whitespace)" do
          let(:content) { '"hello"' }
          let(:tokens)  { ['hello'] }

          it "should tokenize correctly" do
            should == tokenized_version
          end
        end

        context "with two tokens delimited by white space" do
          let(:content) { 'bon voyage' }
          let(:tokens)  { ['bon', 'voyage'] }

          it "should tokenize correctly" do
            should == tokenized_version
          end
        end

        context "with four tokens delimited by white space" do
          let(:content) { 'this is a test' }
          let(:tokens)  { ['this', 'is', 'a', 'test'] }

          it "should tokenize correctly" do
            should == tokenized_version
          end
        end

        context "with a single XML token" do
          let(:content) { [Token.new.tap { |t| t << 'San Francisco' }] }
          let(:tokens)  { ['San Francisco'] }

          it "should tokenize correctly" do
            should == tokenized_version
          end
        end

        context "with a mixture of token types" do
          let(:content) do
            [
              'Welcome to "San Francisco"',
              Token.new.tap { |t| t << 'Have Fun!' }
            ]
          end

          let(:tokens) { ['Welcome', 'to', 'San Francisco', 'Have Fun!'] }

          it "should tokenize correctly" do
            should == tokenized_version
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

          grammar.should_not == normalized_grammar
          grammar.normalize_whitespace
          grammar.should == normalized_grammar
        end
      end

      describe "matching against an input string" do
        before do
          subject.inline!
          subject.tokenize!
          subject.normalize_whitespace
        end

        context "with a grammar that takes a single specific digit" do
          subject do
            GRXML.draw :mode => :dtmf, :root => 'digit' do
              rule :id => 'digit' do
                '6'
              end
            end
          end

          it "should match '6'" do
            expected_match = GRXML::Match.new :mode           => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '6',
                                              :interpretation => '6'
            subject.match('6').should == expected_match
          end

          %w{1 2 3 4 5 7 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes two specific digits" do
          subject do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                '5 6'
              end
            end
          end

          it "should match '56'" do
            expected_match = GRXML::Match.new :mode           => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '56',
                                              :interpretation => '56'
            subject.match('56').should == expected_match
          end

          %w{* *7 #6 6* 1 2 3 4 5 6 7 8 9 10 65 57 46 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes star and a digit" do
          subject do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                '* 6'
              end
            end
          end

          it "should match '*6'" do
            expected_match = GRXML::Match.new :mode           => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '*6',
                                              :interpretation => '*6'
            subject.match('*6').should == expected_match
          end

          %w{* *7 #6 6* 1 2 3 4 5 6 7 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes hash and a digit" do
          subject do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                '# 6'
              end
            end
          end

          it "should match '#6'" do
            expected_match = GRXML::Match.new :mode           => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '#6',
                                              :interpretation => '#6'
            subject.match('#6').should == expected_match
          end

          %w{* *6 #7 6* 1 2 3 4 5 6 7 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes two specific digits, via a ruleref, and whitespace normalization" do
          subject do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                ruleref :uri => '#star'
                '" 6 "'
              end

              rule :id => 'star' do
                '" * "'
              end
            end
          end

          it "should match '*6'" do
            expected_match = GRXML::Match.new :mode           => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '*6',
                                              :interpretation => '*6'
            subject.match('*6').should == expected_match
          end

          %w{* *7 #6 6* 1 2 3 4 5 6 7 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes two specific digits with the second being an alternative" do
          subject do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                string '*'
                one_of do
                  item { '6' }
                  item { '7' }
                end
              end
            end
          end

          it "should match '*6'" do
            expected_match = GRXML::Match.new :mode           => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '*6',
                                              :interpretation => '*6'
            subject.match('*6').should == expected_match
          end

          it "should match '*7'" do
            expected_match = GRXML::Match.new :mode           => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '*7',
                                              :interpretation => '*7'
            subject.match('*7').should == expected_match
          end

          %w{* *8 #6 6* 1 2 3 4 5 6 7 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a specific digit, followed by a specific digit repeated an exact number of times" do
          subject do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                string '1'
                item :repeat => 2 do
                  '6'
                end
              end
            end
          end

          it "should match '166'" do
            expected_match = GRXML::Match.new :mode           => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '166',
                                              :interpretation => '166'
            subject.match('166').should == expected_match
          end

          %w{1 16 1666 16666 17}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a specific digit, followed by a specific digit repeated within a range" do
          subject do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                string '1'
                item :repeat => 0..3 do
                  '6'
                end
              end
            end
          end

          %w{1 16 166 1666}.each do |input|
            it "should match '#{input}'" do
              expected_match = GRXML::Match.new :mode           => :dtmf,
                                                :confidence     => 1,
                                                :utterance      => input,
                                                :interpretation => input
              subject.match(input).should == expected_match
            end
          end

          %w{6 16666 17}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a specific digit, followed by a specific digit repeated a minimum number of times" do
          subject do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                string '1'
                item :repeat => '2-' do
                  '6'
                end
              end
            end
          end

          %w{166 1666 16666}.each do |input|
            it "should match '#{input}'" do
              expected_match = GRXML::Match.new :mode           => :dtmf,
                                                :confidence     => 1,
                                                :utterance      => input,
                                                :interpretation => input
              subject.match(input).should == expected_match
            end
          end

          %w{1 16 17}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end
      end
    end # Grammar
  end # GRXML
end # RubySpeech
