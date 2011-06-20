%w{
  active_support/dependencies/autoload
  active_support/core_ext/object/blank
  niceogiri
}.each { |f| require f }

module RubySpeech
  extend ActiveSupport::Autoload

  autoload :SSML
  autoload :Version
end
