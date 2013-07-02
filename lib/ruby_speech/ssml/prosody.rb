module RubySpeech
  module SSML
    ##
    # The prosody element permits control of the pitch, speaking rate and volume of the speech output.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.2.4
    #
    # Although each attribute individually is optional, it is an error if no attributes are specified when the prosody element is used. The "x-foo" attribute value names are intended to be mnemonics for "extra foo". Note also that customary pitch levels and standard pitch ranges may vary significantly by language, as may the meanings of the labelled values for pitch targets and ranges.
    #
    # The duration attribute takes precedence over the rate attribute. The contour attribute takes precedence over the pitch and range attributes.
    #
    # The default value of all prosodic attributes is no change. For example, omitting the rate attribute means that the rate is the same within the element as outside.
    #
    class Prosody < Element

      %w{
        audio
        break
        desc
        emphasis
        mark
        p
        phoneme
        s
        say_as
        speak
        sub
        voice
      }.each { |f| require "ruby_speech/ssml/#{f}" }

      register :prosody

      VALID_PITCHES     = [:'x-low', :low, :medium, :high, :'x-high', :default].freeze
      VALID_VOLUMES     = [:silent, :'x-soft', :soft, :medium, :loud, :'x-loud', :default].freeze
      VALID_RATES       = [:'x-slow', :slow, :medium, :fast, :'x-fast', :default].freeze
      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, S, SayAs, Sub, Voice].freeze

      ##
      # The baseline pitch for the contained text. Although the exact meaning of "baseline pitch" will vary across synthesis processors, increasing/decreasing this value will typically increase/decrease the approximate pitch of the output. Legal values are: a number followed by "Hz", a relative change or "x-low", "low", "medium", "high", "x-high", or "default". Labels "x-low" through "x-high" represent a sequence of monotonically non-decreasing pitch levels.
      #
      # @return [Symbol, String]
      #
      def pitch
        value = read_attr :pitch
        return unless value
        if value.include?('Hz')
          value
        elsif VALID_PITCHES.include?(value.to_sym)
          value.to_sym
        end
      end

      ##
      # @param [Symbol, String] p
      #
      # @raises ArgumentError if p is not a string that contains 'Hz' or one of VALID_PITCHES
      #
      def pitch=(p)
        set_frequency_attribute :pitch, p
      end

      ##
      # The actual pitch contour for the contained text.
      #
      # The pitch contour is defined as a set of white space-separated targets at specified time positions in the speech output. The algorithm for interpolating between the targets is processor-specific. In each pair of the form (time position,target), the first value is a percentage of the period of the contained text (a number followed by "%") and the second value is the value of the pitch attribute (a number followed by "Hz", a relative change, or a label value). Time position values outside 0% to 100% are ignored. If a pitch value is not defined for 0% or 100% then the nearest pitch target is copied. All relative values for the pitch are relative to the pitch value just before the contained text.
      #
      # @return [Symbol]
      #
      def contour
        read_attr :contour
      end

      ##
      # @param [String] v
      #
      def contour=(v)
        self[:contour] = v
      end

      ##
      # The pitch range (variability) for the contained text. Although the exact meaning of "pitch range" will vary across synthesis processors, increasing/decreasing this value will typically increase/decrease the dynamic range of the output pitch. Legal values are: a number followed by "Hz", a relative change or "x-low", "low", "medium", "high", "x-high", or "default". Labels "x-low" through "x-high" represent a sequence of monotonically non-decreasing pitch ranges.
      #
      # @return [Symbol]
      #
      def range
        value = read_attr :range
        return unless value
        if value.include?('Hz')
          value
        elsif VALID_PITCHES.include?(value.to_sym)
          value.to_sym
        end
      end

      ##
      # @param [Symbol, String] p
      #
      # @raises ArgumentError if p is not a string that contains 'Hz' or one of VALID_PITCHES
      #
      def range=(p)
        set_frequency_attribute :range, p
      end

      ##
      # A change in the speaking rate for the contained text. Legal values are: a relative change or "x-slow", "slow", "medium", "fast", "x-fast", or "default". Labels "x-slow" through "x-fast" represent a sequence of monotonically non-decreasing speaking rates. When a number is used to specify a relative change it acts as a multiplier of the default rate. For example, a value of 1 means no change in speaking rate, a value of 2 means a speaking rate twice the default rate, and a value of 0.5 means a speaking rate of half the default rate. The default rate for a voice depends on the language and dialect and on the personality of the voice. The default rate for a voice should be such that it is experienced as a normal speaking rate for the voice when reading aloud text. Since voices are processor-specific, the default rate will be as well.
      #
      # @return [Symbol, Float]
      #
      def rate
        value = read_attr :rate
        return unless value
        if VALID_RATES.include?(value.to_sym)
          value.to_sym
        else
          value.to_f
        end
      end

      ##
      # @param [Symbol, Numeric] v
      #
      # @raises ArgumentError if v is not either a positive Numeric or one of VALID_RATES
      #
      def rate=(v)
        raise ArgumentError, "You must specify a valid rate ([positive-number](multiplier), #{VALID_RATES.map(&:inspect).join ', '})" unless (v.is_a?(Numeric) && v >= 0) || VALID_RATES.include?(v)
        self[:rate] = v
      end

      ##
      # A value in seconds for the desired time to take to read the element contents.
      #
      # @return [Integer]
      #
      def duration
        read_attr :duration, :to_i
      end

      ##
      # @param [Numeric] t
      #
      # @raises ArgumentError if t is not a positive numeric value
      #
      def duration=(t)
        set_time_attribute :duration, t
      end

      ##
      # The volume for the contained text in the range 0.0 to 100.0 (higher values are louder and specifying a value of zero is equivalent to specifying "silent"). Legal values are: number, a relative change or "silent", "x-soft", "soft", "medium", "loud", "x-loud", or "default". The volume scale is linear amplitude. The default is 100.0. Labels "silent" through "x-loud" represent a sequence of monotonically non-decreasing volume levels.
      #
      # @return [Symbol, Float]
      #
      def volume
        value = read_attr :volume
        return unless value
        if VALID_VOLUMES.include?(value.to_sym)
          value.to_sym
        else
          value.to_f
        end
      end

      ##
      # @param [Numeric, Symbol] v
      #
      # @raises ArgumentError if v is not one of VALID_VOLUMES or a numeric value between 0.0 and 100.0
      #
      def volume=(v)
        raise ArgumentError, "You must specify a valid volume ([positive-number](0.0 -> 100.0), #{VALID_VOLUMES.map(&:inspect).join ', '})" unless (v.is_a?(Numeric) && (0..100).include?(v)) || VALID_VOLUMES.include?(v)
        self[:volume] = v
      end

      def <<(arg)
        raise InvalidChildError, "A Prosody can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :pitch, :contour, :range, :rate, :duration, :volume
      end

      private

      def set_frequency_attribute(key, value)
        hz = value.is_a?(String) && value.include?('Hz') && value.to_f > 0
        raise ArgumentError, "You must specify a valid #{key} (\"[positive-number]Hz\", #{VALID_PITCHES.map(&:inspect).join ', '})" unless hz || VALID_PITCHES.include?(value)
        self[key] = value
      end
    end # Prosody
  end # SSML
end # RubySpeech
