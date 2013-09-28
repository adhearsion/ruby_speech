require 'spec_helper'

describe RubySpeech::GRXML::Builtins do
  let(:matcher) { RubySpeech::GRXML::Matcher.new grammar }
  let(:result) { matcher.match input }

  describe "boolean" do
    let(:grammar) { subject.boolean }

    {
      '1' => 'true',
      '2' => 'false',
    }.each do |input, interpretation|
      describe "with input '#{input}'" do
        let(:input) { input }

        it "should max-match" do
          result.should be_a(RubySpeech::GRXML::MaxMatch)
          result.utterance.should eql(input)
        end

        it "should return the correct interpretation" do
          result.interpretation.should eql(interpretation)
        end
      end
    end

    %w{0 3 10}.each do |input|
      describe "with input '#{input}'" do
        let(:input) { input }

        it "should not match" do
          result.should be_a(RubySpeech::GRXML::NoMatch)
        end
      end
    end
  end

  describe "currency" do
    let(:grammar) { subject.currency }

    {
      '1*01' => 'dtmf-1 dtmf-star dtmf-0 dtmf-1',
      '01*00' => 'dtmf-0 dtmf-1 dtmf-star dtmf-0 dtmf-0',
      '100000000000*00' => 'dtmf-1 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-star dtmf-0 dtmf-0',
      '0*08'  => 'dtmf-0 dtmf-star dtmf-0 dtmf-8',
      '*59'   => 'dtmf-star dtmf-5 dtmf-9',
    }.each do |input, interpretation|
      describe "with input '#{input}'" do
        let(:input) { input }

        it "should max-match" do
          result.should be_a(RubySpeech::GRXML::MaxMatch)
          result.utterance.should eql(input)
        end

        it "should return the correct interpretation" do
          result.interpretation.should eql(interpretation)
        end
      end
    end

    {
      '0'     => 'dtmf-0',
      '0*0'   => 'dtmf-0 dtmf-star dtmf-0',
      '10*5'  => 'dtmf-1 dtmf-0 dtmf-star dtmf-5',
      '123'   => 'dtmf-1 dtmf-2 dtmf-3',
      '123*'  => 'dtmf-1 dtmf-2 dtmf-3 dtmf-star',
    }.each do |input, interpretation|
      describe "with input '#{input}'" do
        let(:input) { input }

        it "should match" do
          result.should be_a(RubySpeech::GRXML::Match)
          result.utterance.should eql(input)
        end

        it "should return the correct interpretation" do
          result.interpretation.should eql(interpretation)
        end
      end
    end

    %w{#}.each do |input|
      describe "with input '#{input}'" do
        let(:input) { input }

        it "should not match" do
          result.should be_a(RubySpeech::GRXML::NoMatch)
        end
      end
    end
  end
end
