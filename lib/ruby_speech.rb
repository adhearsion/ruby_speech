%w{
  active_support/dependencies/autoload
  active_support/core_ext/object/blank
  active_support/core_ext/numeric/time
  niceogiri
}.each { |f| require f }

module RubySpeech
  extend ActiveSupport::Autoload

  autoload :Version

  autoload :SSML
  autoload :GRXML
  autoload :XML
end
