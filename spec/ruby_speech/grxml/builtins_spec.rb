require 'spec_helper'

describe RubySpeech::GRXML::Builtins do
  let(:matcher) { RubySpeech::GRXML::Matcher.new grammar }

  describe "currency" do
    let(:grammar) { subject.currency }

    {
      '1*01' => 'dtmf-1 dtmf-star dtmf-0 dtmf-1',
      '01*00' => 'dtmf-0 dtmf-1 dtmf-star dtmf-0 dtmf-0',
      '100000000000*00' => 'dtmf-1 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-star dtmf-0 dtmf-0',
      '0*08'  => 'dtmf-0 dtmf-star dtmf-0 dtmf-8',
      '*59'   => 'dtmf-star dtmf-5 dtmf-9',
    }.each do |input, interpretation|
      it "should max-match '#{input}'" do
        matcher.match(input).should == RubySpeech::GRXML::MaxMatch.new(confidence: 1,
          interpretation: interpretation,
          mode: :dtmf,
          utterance: input)
      end
    end

    {
      '0'     => 'dtmf-0',
      '0*0'   => 'dtmf-0 dtmf-star dtmf-0',
      '10*5'  => 'dtmf-1 dtmf-0 dtmf-star dtmf-5',
      '123'   => 'dtmf-1 dtmf-2 dtmf-3',
      '123*'  => 'dtmf-1 dtmf-2 dtmf-3 dtmf-star',
    }.each do |input, interpretation|
      it "should match '#{input}'" do
        matcher.match(input).should == RubySpeech::GRXML::Match.new(confidence: 1,
          interpretation: interpretation,
          mode: :dtmf,
          utterance: input)
      end
    end

    %w{#}.each do |input|
      it "should not match '#{input}'" do
        matcher.match(input).should == RubySpeech::GRXML::NoMatch.new
      end
    end
  end
end
