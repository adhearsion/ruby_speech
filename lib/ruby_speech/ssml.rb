module RubySpeech
  module SSML
    InvalidChildError = Class.new StandardError

    SSML_NAMESPACE = 'http://www.w3.org/2001/10/synthesis'

    %w{
      audio
      break
      desc
      element
      emphasis
      mark
      p
      phoneme
      prosody
      s
      say_as
      speak
      sub
      voice
    }.each { |f| require "ruby_speech/ssml/#{f}" }

    def self.draw(*args, &block)
      document = Nokogiri::XML::Document.new
      Speak.new(document, *args).tap do |speak|
        document.root = speak.node
        block_return = speak.eval_dsl_block &block
        speak << block_return if block_return.is_a?(String)
      end
    end

    def self.import(other)
      Element.import other
    end
  end # SSML
end # RubySpeech
