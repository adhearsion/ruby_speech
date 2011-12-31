module RubySpeech
  module SSML
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Audio
      autoload :Break
      autoload :Element
      autoload :Emphasis
      autoload :Mark
      autoload :P
      autoload :Prosody
      autoload :S
      autoload :SayAs
      autoload :Speak
      autoload :Voice
    end

    InvalidChildError = Class.new StandardError

    SSML_NAMESPACE = 'http://www.w3.org/2001/10/synthesis'

    def self.draw(&block)
      Speak.new.tap do |speak|
        block_return = speak.eval_dsl_block &block
        speak << block_return if block_return.is_a?(String)
      end
    end

    def self.import(other)
      Element.import other
    end
  end # SSML
end # RubySpeech

ActiveSupport::Autoload.eager_autoload!
