%w{
  active_support/core_ext/object/blank
  active_support/core_ext/numeric/time
  active_support/core_ext/enumerable
  nokogiri

  ruby_speech/version
  ruby_speech/ssml
  ruby_speech/grxml
  ruby_speech/nlsml
}.each { |f| require f }

module RubySpeech
  def self.parse(string)
    document = Nokogiri::XML.parse string, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS
    namespace = document.root.namespace
    case namespace && namespace.href
    when SSML::SSML_NAMESPACE
      SSML::Element.import string
    when GRXML::GRXML_NAMESPACE
      GRXML::Element.import string
    when NLSML::NLSML_NAMESPACE, nil
      NLSML::Document.new document
    end
  end
end
