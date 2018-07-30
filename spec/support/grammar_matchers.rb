require 'rspec/expectations'

RSpec::Matchers.define :not_match do |input|
  match do |grammar|
    @result = RubySpeech::GRXML::Matcher.new(grammar).match(input)
    @result.is_a?(RubySpeech::GRXML::NoMatch)
  end

  failure_message do |grammar|
    "expected #{grammar} to not match #{input}, but received a #{@result.class}"
  end
end

RSpec::Matchers.define :potentially_match do |input|
  match do |grammar|
    @result = RubySpeech::GRXML::Matcher.new(grammar).match(input)
    @result.is_a?(RubySpeech::GRXML::PotentialMatch)
  end

  failure_message do |grammar|
    "expected #{grammar} to potentially match #{input}, but received a #{@result.class}"
  end
end

RSpec::Matchers.define :match do |input|
  match do |grammar|
    @result = RubySpeech::GRXML::Matcher.new(grammar).match(input)
    @result.is_a?(RubySpeech::GRXML::Match) && (@interpretation ? @result.interpretation == @interpretation : true)
  end

  chain :and_interpret_as do |interpretation|
    @interpretation = interpretation
  end

  description do
    %{#{super()} and interpret as "#{@interpretation}"}
  end

  failure_message do |grammar|
    messages = []
    unless @result.is_a?(RubySpeech::GRXML::Match)
      messages << "expected #{grammar} to match, got a #{@result.class}"
    end

    if @result.respond_to?(:interpretation) && @result.interpretation != @interpretation
      messages << %{expected interpretation to be "#{@interpretation}" but received "#{@result.interpretation}"}
    end

    messages.join(' ')
  end
end

RSpec::Matchers.define :max_match do |input|
  match do |grammar|
    @result = RubySpeech::GRXML::Matcher.new(grammar).match(input)
    @result.is_a?(RubySpeech::GRXML::MaxMatch) && (@interpretation ? @result.interpretation == @interpretation : true)
  end

  chain :and_interpret_as do |interpretation|
    @interpretation = interpretation
  end

  description do
    %{#{super()} and interpret as "#{@interpretation}"}
  end

  failure_message do |grammar|
    messages = []
    unless @result.is_a?(RubySpeech::GRXML::MaxMatch)
      messages << "expected #{grammar} to max-match, got a #{@result.class}"
    end

    if @result.respond_to?(:interpretation) && @result.interpretation != @interpretation
      messages << %{expected interpretation to be "#{@interpretation}" but received "#{@result.interpretation}"}
    end

    messages.join(' ')
  end
end
