require 'ruby_speech/ssml/element'
require 'ruby_speech/xml/language'

module RubySpeech
  module SSML
    ##
    # The Speech Synthesis Markup Language is an XML application. The root element is speak.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.1.1
    #
    class Speak < Element

      %w{
        audio
        break
        desc
        emphasis
        mark
        phoneme
        prosody
        s
        say_as
        sub
        voice
      }.each { |f| require "ruby_speech/ssml/#{f}" }

      include XML::Language

      register :speak

      self.defaults = { :version => '1.0', :language => "en-US", namespace: SSML_NAMESPACE }

      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, S, SayAs, Sub, Voice].freeze

      def <<(arg)
        raise InvalidChildError, "A Speak can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :language, :base_uri
      end
    end # Speak
  end # SSML
end # RubySpeech
