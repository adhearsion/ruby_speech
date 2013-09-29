require 'rspec/expectations'

RSpec::Matchers.define :not_match do |input|
  match do |grammar|
    RubySpeech::GRXML::Matcher.new(grammar).match(input).is_a?(RubySpeech::GRXML::NoMatch)
  end
end

RSpec::Matchers.define :match do |input|
  match do |grammar|
    @result = RubySpeech::GRXML::Matcher.new(grammar).match(input)
    @result.is_a?(RubySpeech::GRXML::Match) && @result.interpretation == @interpretation
  end

  chain :and_interpret_as do |interpretation|
    @interpretation = interpretation
  end

  description do
    %{#{default_description} and interpret as "#{@interpretation}"}
  end

  failure_message_for_should do |grammar|
    messages = []
    unless @result.is_a?(RubySpeech::GRXML::Match)
      messages << "expected a match result, got a #{@result.class}"
    end

    unless @result.interpretation == @interpretation
      messages << %{expected interpretation to be "#{@interpretation}" but received "#{@result.interpretation}"}
    end

    messages.join(' ')
  end
end

RSpec::Matchers.define :max_match do |input|
  match do |grammar|
    @result = RubySpeech::GRXML::Matcher.new(grammar).match(input)
    @result.is_a?(RubySpeech::GRXML::MaxMatch) && @result.interpretation == @interpretation
  end

  chain :and_interpret_as do |interpretation|
    @interpretation = interpretation
  end

  description do
    %{#{default_description} and interpret as "#{@interpretation}"}
  end

  failure_message_for_should do |grammar|
    messages = []
    unless @result.is_a?(RubySpeech::GRXML::Match)
      messages << "expected a match result, got a #{@result.class}"
    end

    unless @result.interpretation == @interpretation
      messages << %{expected interpretation to be "#{@interpretation}" but received "#{@result.interpretation}"}
    end

    messages.join(' ')
  end
end
