require 'spec_helper'

module RubySpeech
  module GRXML
    describe Matcher do
      let(:grammar) { nil }

      subject { described_class.new grammar }

      describe "matching against an input string" do
        context "with a grammar that takes a single specific digit" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digit' do
              rule :id => 'digit' do
                '6'
              end
            end
          end

          it "should max-match '6'" do
            input = '6'
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '6',
                                              :interpretation => 'dtmf-6'
            subject.match(input).should == expected_match
            input.should == '6'
          end

          it "should potentially match an empty buffer" do
            subject.match('').should == GRXML::PotentialMatch.new
          end

          %w{1 2 3 4 5 7 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar with SISR tags" do
          let :grammar do
            RubySpeech::GRXML.draw mode: 'dtmf', root: 'options', tag_format: 'semantics/1.0-literals' do
              rule id: 'options', scope: 'public' do
                item do
                  one_of do
                    item do
                      tag { '1' }
                      '1'
                    end
                    item do
                      tag { 'bar' }
                      '2'
                    end
                    item do
                      tag { 'baz' }
                      '3'
                    end
                    item do
                      tag { 'lala' }
                      '4'
                    end
                  end
                end
              end
            end
          end

          it "should return the literal tag interpretation" do
            expected_match = GRXML::MaxMatch.new mode: :dtmf, confidence: 1,
              utterance: '2', interpretation: 'bar'
            subject.match('2').should == expected_match
          end
        end

        context "with a grammar that takes two specific digits" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                '5 6'
              end
            end
          end

          it "should maximally match '56'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '56',
                                              :interpretation => 'dtmf-5 dtmf-6'
            subject.match('56').should == expected_match
          end

          it "should potentially match '5'" do
            input = '5'
            subject.match(input).should == GRXML::PotentialMatch.new
            input.should == '5'
          end

          %w{* *7 #6 6* 1 2 3 4 6 7 8 9 10 65 57 46 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes star and a digit" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                '* 6'
              end
            end
          end

          it "should maximally match '*6'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '*6',
                                              :interpretation => 'dtmf-star dtmf-6'
            subject.match('*6').should == expected_match
          end

          it "should potentially match '*'" do
            subject.match('*').should == GRXML::PotentialMatch.new
          end

          %w{*7 #6 6* 1 2 3 4 5 6 7 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes hash and a digit" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                '# 6'
              end
            end
          end

          it "should maximally match '#6'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '#6',
                                              :interpretation => 'dtmf-pound dtmf-6'
            subject.match('#6').should == expected_match
          end

          it "should potentially match '#'" do
            subject.match('#').should == GRXML::PotentialMatch.new
          end

          %w{* *6 #7 6* 1 2 3 4 5 6 7 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes two specific digits, via a ruleref, and whitespace normalization" do
          let(:grammar) do
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

          it "should maximally match '*6'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '*6',
                                              :interpretation => 'dtmf-star dtmf-6'
            subject.match('*6').should == expected_match
          end

          it "should potentially match '*'" do
            subject.match('*').should == GRXML::PotentialMatch.new
          end

          %w{*7 #6 6* 1 2 3 4 5 6 7 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a single digit alternative" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                one_of do
                  item { '6' }
                  item { '7' }
                end
              end
            end
          end

          it "should maximally match '6'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '6',
                                              :interpretation => 'dtmf-6'
            subject.match('6').should == expected_match
          end

          it "should maximally match '7'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '7',
                                              :interpretation => 'dtmf-7'
            subject.match('7').should == expected_match
          end

          %w{* # 1 2 3 4 5 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a double digit alternative" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                one_of do
                  item do
                    token { '6' }
                    token { '5' }
                  end
                  item do
                    token { '7' }
                    token { '2' }
                  end
                end
              end
            end
          end

          it "should maximally match '65'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '65',
                                              :interpretation => 'dtmf-6 dtmf-5'
            subject.match('65').should == expected_match
          end

          it "should maximally match '72'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '72',
                                              :interpretation => 'dtmf-7 dtmf-2'
            subject.match('72').should == expected_match
          end

          %w{6 7}.each do |input|
            it "should potentially match '#{input}'" do
              subject.match(input).should == GRXML::PotentialMatch.new
            end
          end

          %w{* # 1 2 3 4 5 8 9 10 66 26 61 75}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a triple digit alternative" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                one_of do
                  item do
                    token { '6' }
                    token { '5' }
                    token { '2' }
                  end
                  item do
                    token { '7' }
                    token { '2' }
                    token { '8' }
                  end
                end
              end
            end
          end

          it "should maximally match '652'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '652',
                                              :interpretation => 'dtmf-6 dtmf-5 dtmf-2'
            subject.match('652').should == expected_match
          end

          it "should maximally match '728'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '728',
                                              :interpretation => 'dtmf-7 dtmf-2 dtmf-8'
            subject.match('728').should == expected_match
          end

          %w{6 65 7 72}.each do |input|
            it "should potentially match '#{input}'" do
              subject.match(input).should == GRXML::PotentialMatch.new
            end
          end

          %w{* # 1 2 3 4 5 8 9 10 66 26 61 75 729 654}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes two specific digits with the second being an alternative" do
          let(:grammar) do
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

          it "should maximally match '*6'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '*6',
                                              :interpretation => 'dtmf-star dtmf-6'
            subject.match('*6').should == expected_match
          end

          it "should maximally match '*7'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '*7',
                                              :interpretation => 'dtmf-star dtmf-7'
            subject.match('*7').should == expected_match
          end

          it "should potentially match '*'" do
            subject.match('*').should == GRXML::PotentialMatch.new
          end

          %w{*8 #6 6* 1 2 3 4 5 6 7 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes two specific digits with the first being an alternative" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                one_of do
                  item { '6' }
                  item { '7' }
                end
                string '*'
              end
            end
          end

          it "should maximally match '6*'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '6*',
                                              :interpretation => 'dtmf-6 dtmf-star'
            subject.match('6*').should == expected_match
          end

          it "should maximally match '7*'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '7*',
                                              :interpretation => 'dtmf-7 dtmf-star'
            subject.match('7*').should == expected_match
          end

          %w{6 7}.each do |input|
            it "should potentially match '#{input}'" do
              subject.match(input).should == GRXML::PotentialMatch.new
            end
          end

          it "should potentially match '7'" do
            subject.match('7').should == GRXML::PotentialMatch.new
          end

          %w{8* 6# *6 *7 1 2 3 4 5 8 9 10 66 26 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a specific digit, followed by a specific digit repeated an exact number of times" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                string '1'
                item :repeat => 2 do
                  '6'
                end
              end
            end
          end

          it "should maximally match '166'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '166',
                                              :interpretation => 'dtmf-1 dtmf-6 dtmf-6'
            subject.match('166').should == expected_match
          end

          %w{1 16}.each do |input|
            it "should potentially match '#{input}'" do
              subject.match(input).should == GRXML::PotentialMatch.new
            end
          end

          %w{1666 16666 17}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a specific digit repeated an exact number of times, followed by a specific digit" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                item :repeat => 2 do
                  '6'
                end
                string '1'
              end
            end
          end

          it "should maximally match '661'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '661',
                                              :interpretation => 'dtmf-6 dtmf-6 dtmf-1'
            subject.match('661').should == expected_match
          end

          %w{6 66}.each do |input|
            it "should potentially match '#{input}'" do
              subject.match(input).should == GRXML::PotentialMatch.new
            end
          end

          %w{61 6661 66661 71 771}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a specific digit, followed by a specific digit repeated within a range" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                string '1'
                item :repeat => 0..3 do
                  '6'
                end
              end
            end
          end

          it "should maximally match '1666'" do
            expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                              :confidence     => 1,
                                              :utterance      => '1666',
                                              :interpretation => 'dtmf-1 dtmf-6 dtmf-6 dtmf-6'
            subject.match('1666').should == expected_match
          end

          {
            '1' => 'dtmf-1',
            '16' => 'dtmf-1 dtmf-6',
            '166' => 'dtmf-1 dtmf-6 dtmf-6',
          }.each_pair do |input, interpretation|
            it "should match '#{input}'" do
              expected_match = GRXML::Match.new :mode           => :dtmf,
                                                :confidence     => 1,
                                                :utterance      => input,
                                                :interpretation => interpretation
              subject.match(input).should == expected_match
            end
          end

          %w{6 16666 17}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a a specific digit repeated within a range, followed by specific digit" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                item :repeat => 0..3 do
                  '6'
                end
                string '1'
              end
            end
          end

          {
            '1' => 'dtmf-1',
            '61' => 'dtmf-6 dtmf-1',
            '661' => 'dtmf-6 dtmf-6 dtmf-1',
            '6661' => 'dtmf-6 dtmf-6 dtmf-6 dtmf-1'
          }.each_pair do |input, interpretation|
            it "should maximally match '#{input}'" do
              expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                                :confidence     => 1,
                                                :utterance      => input,
                                                :interpretation => interpretation
              subject.match(input).should == expected_match
            end
          end

          %w{6 66 666}.each do |input|
            it "should potentially match '#{input}'" do
              subject.match(input).should == GRXML::PotentialMatch.new
            end
          end

          %w{66661 71}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a specific digit, followed by a specific digit repeated a minimum number of times" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                string '1'
                item :repeat => '2-' do
                  '6'
                end
              end
            end
          end

          {
            '166' => 'dtmf-1 dtmf-6 dtmf-6',
            '1666' => 'dtmf-1 dtmf-6 dtmf-6 dtmf-6',
            '16666' => 'dtmf-1 dtmf-6 dtmf-6 dtmf-6 dtmf-6'
          }.each_pair do |input, interpretation|
            it "should match '#{input}'" do
              expected_match = GRXML::Match.new :mode           => :dtmf,
                                                :confidence     => 1,
                                                :utterance      => input,
                                                :interpretation => interpretation
              subject.match(input).should == expected_match
            end
          end

          %w{1 16}.each do |input|
            it "should potentially match '#{input}'" do
              subject.match(input).should == GRXML::PotentialMatch.new
            end
          end

          %w{7 17}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a specific digit repeated a minimum number of times, followed by a specific digit" do
          let(:grammar) do
            GRXML.draw :mode => :dtmf, :root => 'digits' do
              rule :id => 'digits' do
                item :repeat => '2-' do
                  '6'
                end
                string '1'
              end
            end
          end

          {
            '661' => 'dtmf-6 dtmf-6 dtmf-1',
            '6661' => 'dtmf-6 dtmf-6 dtmf-6 dtmf-1',
            '66661' => 'dtmf-6 dtmf-6 dtmf-6 dtmf-6 dtmf-1'
          }.each_pair do |input, interpretation|
            it "should maximally match '#{input}'" do
              expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                                :confidence     => 1,
                                                :utterance      => input,
                                                :interpretation => interpretation
              subject.match(input).should == expected_match
            end
          end

          %w{6 66}.each do |input|
            it "should potentially match '#{input}'" do
              subject.match(input).should == GRXML::PotentialMatch.new
            end
          end

          %w{7 71 61}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end

        context "with a grammar that takes a 4 digit pin terminated by hash, or the *9 escape sequence" do
          let(:grammar) do
            RubySpeech::GRXML.draw :mode => :dtmf, :root => 'pin' do
              rule :id => 'digit' do
                one_of do
                  ('0'..'9').map { |d| item { d } }
                end
              end

              rule :id => 'pin', :scope => 'public' do
                one_of do
                  item do
                    item :repeat => '4' do
                      ruleref :uri => '#digit'
                    end
                    "#"
                  end
                  item do
                    "\* 9"
                  end
                end
              end
            end
          end

          {
            '*9' => 'dtmf-star dtmf-9',
            '1234#' => 'dtmf-1 dtmf-2 dtmf-3 dtmf-4 dtmf-pound',
            '5678#' => 'dtmf-5 dtmf-6 dtmf-7 dtmf-8 dtmf-pound',
            '1111#' => 'dtmf-1 dtmf-1 dtmf-1 dtmf-1 dtmf-pound'
          }.each_pair do |input, interpretation|
            it "should maximally match '#{input}'" do
              expected_match = GRXML::MaxMatch.new :mode        => :dtmf,
                                                :confidence     => 1,
                                                :utterance      => input,
                                                :interpretation => interpretation
              subject.match(input).should == expected_match
            end
          end

          %w{* 1 12 123 1234}.each do |input|
            it "should potentially match '#{input}'" do
              subject.match(input).should == GRXML::PotentialMatch.new
            end
          end

          %w{11111 #1111 *7}.each do |input|
            it "should not match '#{input}'" do
              subject.match(input).should == GRXML::NoMatch.new
            end
          end
        end
      end
    end # Grammar
  end # GRXML
end # RubySpeech
