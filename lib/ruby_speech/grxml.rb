module RubySpeech
  module GRXML
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Element
      autoload :Grammar
      autoload :Rule
      autoload :Item
      autoload :OneOf
      autoload :Ruleref
      autoload :Tag
      autoload :Token
    end

    autoload :Match
    autoload :NoMatch

    InvalidChildError = Class.new StandardError

    GRXML_NAMESPACE = 'http://www.w3.org/2001/06/grammar'

    def self.draw(attributes = {}, &block)
      Grammar.new(attributes).tap do |grammar|
        block_return = grammar.eval_dsl_block &block
        grammar << block_return if block_return.is_a?(String)
      end.assert_has_matching_root_rule
    end

    def self.import(other)
      Element.import other
    end
  end # GRXML
end # RubySpeech

ActiveSupport::Autoload.eager_autoload!
