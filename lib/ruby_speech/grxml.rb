require 'ruby_speech/grxml/matcher'
require 'ruby_speech/grxml/element'

module RubySpeech
  module GRXML
    InvalidChildError = Class.new StandardError
    MissingReferenceError = Class.new StandardError
    ReferentialLoopError = Class.new StandardError

    GRXML_NAMESPACE = 'http://www.w3.org/2001/06/grammar'

    %w{
      builtins
      grammar
      rule
      item
      one_of
      ruleref
      tag
      token
    }.each { |f| require "ruby_speech/grxml/#{f}" }

    def self.draw(attributes = {}, &block)
      document = Nokogiri::XML::Document.new
      Grammar.new(document, attributes).tap do |grammar|
        document.root = grammar.node
        block_return = grammar.eval_dsl_block &block
        grammar << block_return if block_return.is_a?(String)
      end.assert_has_matching_root_rule
    end

    def self.import(other)
      Element.import other
    end

    URI_REGEX = /builtin:(?<class>.*)\/(?<type>\w*)(\?)?(?<query>(\w*=\w*;?)*)?/.freeze

    #
    # Fetch a builtin grammar by URI
    #
    # @param [String] uri The builtin grammar URI of the form "builtin:dtmf/type?param=value"
    #
    # @return [RubySpeech::GRXML::Grammar] a grammar from the builtin set
    #
    def self.from_uri(uri)
      match = uri.match(URI_REGEX)
      raise ArgumentError, "Only builtin grammars are supported" unless match
      raise ArgumentError, "Only DTMF builtins are supported" unless match[:class] == 'dtmf'
      type = match[:type]
      query = {}
      match[:query].split(';').each do |s|
        key, value = s.split('=')
        query[key] = value
      end
      raise ArgumentError, "#{type} is an invalid builtin grammar" unless Builtins.respond_to?(type)
      Builtins.send type, query
    end
  end # GRXML
end # RubySpeech
