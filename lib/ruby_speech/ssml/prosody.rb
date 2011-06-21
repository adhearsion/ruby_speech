module RubySpeech
  module SSML
    class Prosody < Niceogiri::XML::Node
      VALID_PITCHES = [:'x-low', :low, :medium, :high, :'x-high', :default].freeze
      VALID_VOLUMES = [:silent, :'x-soft', :soft, :medium, :loud, :'x-loud', :default].freeze
      VALID_RATES   = [:'x-slow', :slow, :medium, :fast, :'x-fast', :default].freeze

      def self.new
        super('prosody')
      end

      def pitch
        value = read_attr :pitch
        if value.include?('Hz')
          value
        elsif VALID_PITCHES.include?(value.to_sym)
          value.to_sym
        end
      end

      def pitch=(p)
        hz = p.is_a?(String) && p.include?('Hz') && p.to_f > 0
        raise ArgumentError, "You must specify a valid pitch (\"[positive-number]Hz\", #{VALID_PITCHES.map(&:inspect).join ', '})" unless hz || VALID_PITCHES.include?(p)
        write_attr :pitch, p
      end

      def contour
        read_attr :contour
      end

      def contour=(v)
        write_attr :contour, v
      end

      def range
        value = read_attr :range
        if value.include?('Hz')
          value
        elsif VALID_PITCHES.include?(value.to_sym)
          value.to_sym
        end
      end

      def range=(p)
        hz = p.is_a?(String) && p.include?('Hz') && p.to_f > 0
        raise ArgumentError, "You must specify a valid range (\"[positive-number]Hz\", #{VALID_PITCHES.map(&:inspect).join ', '})" unless hz || VALID_PITCHES.include?(p)
        write_attr :range, p
      end

      def rate
        value = read_attr :rate
        if VALID_RATES.include?(value.to_sym)
          value.to_sym
        else
          value.to_f
        end
      end

      def rate=(v)
        raise ArgumentError, "You must specify a valid rate ([positive-number](multiplier), #{VALID_RATES.map(&:inspect).join ', '})" unless (v.is_a?(Numeric) && v >= 0) || VALID_RATES.include?(v)
        write_attr :rate, v
      end

      def duration
        read_attr :duration, :to_i
      end

      def duration=(t)
        raise ArgumentError, "You must specify a valid duration (positive float value in seconds)" unless t.is_a?(Numeric) && t >= 0
        write_attr :duration, "#{t}s"
      end

      def volume
        value = read_attr :volume
        if VALID_VOLUMES.include?(value.to_sym)
          value.to_sym
        else
          value.to_f
        end
      end

      def volume=(v)
        raise ArgumentError, "You must specify a valid volume ([positive-number](0.0 -> 100.0), #{VALID_VOLUMES.map(&:inspect).join ', '})" unless (v.is_a?(Numeric) && (0..100).include?(v)) || VALID_VOLUMES.include?(v)
        write_attr :volume, v
      end
    end # Prosody
  end # SSML
end # RubySpeech
