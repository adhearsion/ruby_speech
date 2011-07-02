def be_a_valid_ssml_document
  SSMLMatcher.new
end

class SSMLMatcher
  attr_reader :subject

  def subject=(s)
    if s.is_a? Nokogiri::XML::Document
      @subject = s
    else
      doc = Nokogiri::XML::Document.new
      doc << s
      @subject = doc
    end
  end

  def failure_message
    " expected #{subject} to be a valid SSML document\n#{errors}"
  end

  def negative_failure_message
    " expected #{subject} not to be a valid SSML document"
  end

  def description
    "to be a valid SSML document"
  end

  def matches?(s)
    self.subject = s
    SSML_SCHEMA.valid? subject
  end

  def does_not_match?(s)
    !matches? s
  end

  private

    def errors
      SSML_SCHEMA.validate(subject).map(&:message).join "\n"
    end

end
