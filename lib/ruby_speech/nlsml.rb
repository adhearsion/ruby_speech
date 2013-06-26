require 'ruby_speech/nlsml/document'
require 'ruby_speech/nlsml/builder'

module RubySpeech
  module NLSML
    NLSML_NAMESPACE = 'http://www.ietf.org/xml/ns/mrcpv2'

    def self.draw(options = {}, &block)
      Builder.new(options, &block).document
    end
  end
end
