require 'active_support/dependencies/autoload'
require 'active_support/core_ext/object/blank'

module RubySpeech
  extend ActiveSupport::Autoload

  autoload :SSML
  autoload :Version
end
