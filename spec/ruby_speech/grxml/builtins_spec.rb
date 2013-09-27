require 'spec_helper'

describe RubySpeech::GRXML::Builtins do
  let(:matcher) { RubySpeech::GRXML::Matcher.new grammar }

  describe "currency" do
    let(:grammar) { subject.currency }

    {
      "1*00" => "dtmf-1 dtmf-star dtmf-0 dtmf-0",
      "01*00" => "dtmf-0 dtmf-1 dtmf-star dtmf-0 dtmf-0",
      "100000000000*00" => "dtmf-1 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-0 dtmf-star dtmf-0 dtmf-0",
    }.each do |input, interpretation|
      it "should max-match '#{input}'" do
        matcher.match(input).should == RubySpeech::GRXML::MaxMatch.new(confidence: 1,
          interpretation: interpretation,
          mode: :dtmf,
          utterance: input)
      end
    end

    %w{1 111 1*0}.each do |input|
      it "should potentially match '#{input}'" do
        matcher.match(input).should == RubySpeech::GRXML::PotentialMatch.new
      end
    end

    %w{#}.each do |input|
      it "should not match '#{input}'" do
        matcher.match(input).should == RubySpeech::GRXML::NoMatch.new
      end
    end
  end
end
