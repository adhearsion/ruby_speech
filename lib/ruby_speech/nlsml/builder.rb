module RubySpeech
  module NLSML
    class Builder
      attr_reader :document

      def initialize(options = {}, &block)
        options = {"xmlns" => 'http://www.w3c.org/2000/11/nlsml', "xmlns:xf" => "http://www.w3.org/2000/xforms"}.merge(options)
        @document = Nokogiri::XML::Builder.new do |builder|
          builder.result options do |r|
            apply_block r, &block
          end
        end.doc
      end

      def interpretation(*args, &block)
        if args.last.respond_to?(:has_key?) && args.last.has_key?(:confidence)
          args.last[:confidence] = (args.last[:confidence] * 100).to_i
        end
        @result.send :interpretation, *args, &block
      end

      def model(*args, &block)
        xf_namespaced_element :model, *args, &block
      end

      def instance(*args, &block)
        xf_namespaced_element :instance, *args, &block
      end

      def method_missing(method_name, *args, &block)
        @result.send method_name, *args, &block
      end

      private

      def apply_block(result, &block)
        @result = result
        instance_eval &block
      end

      def xf_namespaced_element(element_name, *args, &block)
        namespace = @result.send :[], 'xf'
        namespace.send element_name, &block
      end
    end
  end
end
