module RubySpeech
  module GRXML
    extend ActiveSupport::Autoload

    autoload :Element
    autoload :Grammar
    #autoload :Dtfm

    InvalidChildError = Class.new StandardError

    GRXML_NAMESPACE = 'http://www.w3.org/2001/06/grammar'

    def self.draw(&block)
      Grammar.new.tap do |grammar|
        block_return = grammar.instance_eval(&block) if block_given?
        grammar << block_return if block_return.is_a?(String)
      end
    end
  end # GRXML
end # RubySpeech
