module RubySpeech
  module SSML
    extend ActiveSupport::Autoload

    autoload :Audio
    autoload :Break
    autoload :Element
    autoload :Emphasis
    autoload :Prosody
    autoload :SayAs
    autoload :Speak
    autoload :Voice

    InvalidChildError = Class.new StandardError

    def self.draw(&block)
      Speak.new.tap do |speak|
        block_return = speak.instance_eval(&block) if block_given?
        speak << block_return if block_return.is_a?(String)
      end
    end
  end # SSML
end # RubySpeech
