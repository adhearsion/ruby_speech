%w{
  active_support/dependencies/autoload
  active_support/core_ext/object/blank
  active_support/core_ext/numeric/time
  active_support/core_ext/enumerable
  niceogiri
}.each { |f| require f }

module RubySpeech
  extend ActiveSupport::Autoload

  autoload :Version

  eager_autoload do
    autoload :GenericElement
    autoload :SSML
    autoload :GRXML
    autoload :NLSML
    autoload :XML
  end
end

ActiveSupport::Autoload.eager_autoload!
