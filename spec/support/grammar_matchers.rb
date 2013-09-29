require 'rspec/expectations'

RSpec::Matchers.define :not_match do |input|
  match do |grammar|
    RubySpeech::GRXML::Matcher.new(grammar).match(input).is_a?(RubySpeech::GRXML::NoMatch)
  end
end

RSpec::Matchers.define :match do |input|
  match do |grammar|
    result = RubySpeech::GRXML::Matcher.new(grammar).match(input)
    result.is_a?(RubySpeech::GRXML::Match) && result.interpretation == @interpretation
  end

  chain :and_interpret_as do |interpretation|
    @interpretation = interpretation
  end

  description do
    %{#{default_description} and interpret as "#{@interpretation}"}
  end
end

RSpec::Matchers.define :max_match do |input|
  match do |grammar|
    result = RubySpeech::GRXML::Matcher.new(grammar).match(input)
    result.is_a?(RubySpeech::GRXML::MaxMatch) && result.interpretation == @interpretation
  end

  chain :and_interpret_as do |interpretation|
    @interpretation = interpretation
  end

  description do
    %{#{default_description} and interpret as "#{@interpretation}"}
  end
end
