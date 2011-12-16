module RubySpeech
  module XML
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Language
    end
  end # XML
end # RubySpeech

ActiveSupport::Autoload.eager_autoload!
