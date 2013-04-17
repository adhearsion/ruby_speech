module RubySpeech
  module NLSML
    class Builder
      attr_reader :document

      def initialize(options = {}, &block)
        options = {'xmlns' => NLSML_NAMESPACE}.merge(options)
        @document = Nokogiri::XML::Builder.new do |builder|
          builder.result options do |r|
            apply_block r, &block
          end
        end.doc
      end

      def interpretation(*args, &block)
        if args.last.respond_to?(:has_key?) && args.last.has_key?(:confidence)
          args.last[:confidence] = args.last[:confidence].to_f
        end
        @result.send :interpretation, *args, &block
      end

      def method_missing(method_name, *args, &block)
        @result.send method_name, *args, &block
      end

      private

      def apply_block(result, &block)
        @result = result
        instance_eval &block
      end
    end
  end
end
