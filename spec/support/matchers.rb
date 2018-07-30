def be_a_valid_grxml_document
  SpeechDocMatcher.new 'GRXML', GRXML_SCHEMA
end

def be_a_valid_ssml_document
  SpeechDocMatcher.new 'SSML', SSML_SCHEMA
end

class SpeechDocMatcher
  attr_reader :subject, :type, :schema

  def initialize(type, schema)
    @type, @schema = type, schema
  end

  def subject=(s)
    @subject = Nokogiri::XML(s.to_xml)
  end

  def failure_message
    " expected #{subject} to be a valid #{type} document\n#{errors}"
  end

  def failure_message_when_negated
    " expected #{subject} not to be a valid #{type} document"
  end

  def description
    "to be a valid #{type} document"
  end

  def matches?(s)
    self.subject = s
    schema.valid? subject
  end

  def does_not_match?(s)
    !matches? s
  end

  private

  def errors
    schema.validate(subject).map(&:message).join "\n"
  end
end
