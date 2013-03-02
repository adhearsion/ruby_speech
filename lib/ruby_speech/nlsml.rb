module RubySpeech
  module NLSML
    extend ActiveSupport::Autoload

    NLSML_NAMESPACE   = 'http://www.w3c.org/2000/11/nlsml'
    XFORMS_NAMESPACE  = 'http://www.w3.org/2000/xforms'

    eager_autoload do
      autoload :Builder
      autoload :Document
    end

    def self.draw(options = {}, &block)
      Builder.new(options, &block).document
    end
  end
end

ActiveSupport::Autoload.eager_autoload!
