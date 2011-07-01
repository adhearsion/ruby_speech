module RubySpeech
  module SSML
    extend ActiveSupport::Autoload

    autoload :Break
    autoload :Emphasis
    autoload :Prosody
    autoload :SayAs
    autoload :Speak
    autoload :Voice

    InvalidChildError = Class.new StandardError
  end # SSML
end # RubySpeech
