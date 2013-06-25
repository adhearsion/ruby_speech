require 'ruby_speech/ssml/element'
require 'ruby_speech/xml/language'

module RubySpeech
  module SSML
    ##
    # The voice element is a production element that requests a change in speaking voice.
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.2.1
    #
    class Voice < Element

      %w{
        audio
        break
        desc
        emphasis
        mark
        p
        phoneme
        prosody
        s
        say_as
        speak
        sub
      }.each { |f| require "ruby_speech/ssml/#{f}" }

      include XML::Language

      register :voice

      VALID_GENDERS = [:male, :female, :neutral].freeze
      VALID_CHILD_TYPES = [Nokogiri::XML::Element, Nokogiri::XML::Text, String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, S, SayAs, Sub, Voice].freeze

      ##
      # Indicates the preferred gender of the voice to speak the contained text. Enumerated values are: "male", "female", "neutral".
      #
      # @return [Symbol]
      #
      def gender
        read_attr :gender, :to_sym
      end

      ##
      # @param [Symbol] g the gender selected from VALID_GENDERS
      #
      # @raises ArgumentError if g is not one of VALID_GENDERS
      #
      def gender=(g)
        raise ArgumentError, "You must specify a valid gender (#{VALID_GENDERS.map(&:inspect).join ', '})" unless VALID_GENDERS.include? g
        self[:gender] = g
      end

      ##
      # Indicates the preferred age in years (since birth) of the voice to speak the contained text.
      #
      # @return [Integer]
      #
      def age
        read_attr :age, :to_i
      end

      ##
      # @param [Integer] i the age of the voice
      #
      # @raises ArgumentError if i is not a non-negative integer
      #
      def age=(i)
        raise ArgumentError, "You must specify a valid age (non-negative integer)" unless i.is_a?(Integer) && i >= 0
        self[:age] = i
      end

      ##
      # Indicates a preferred variant of the other voice characteristics to speak the contained text. (e.g. the second male child voice).
      #
      # @return [Integer]
      #
      def variant
        read_attr :variant, :to_i
      end

      ##
      # @param [Integer] i the variant of the voice
      #
      # @raises ArgumentError if i is not a non-negative integer
      #
      def variant=(i)
        raise ArgumentError, "You must specify a valid variant (positive integer)" unless i.is_a?(Integer) && i > 0
        self[:variant] = i
      end

      ##
      # A processor-specific voice name to speak the contained text.
      #
      # @return [String, Array, nil] the name or names of the voice
      #
      def name
        names = read_attr :name
        return unless names
        names = names.split ' '
        case names.count
        when 0 then nil
        when 1 then names.first
        else names
        end
      end

      ##
      # @param [String, Array] the name or names of the voice. May be an array of names ordered from top preference down. The names must not contain any white space.
      #
      def name=(n)
        # TODO: Raise ArgumentError if names contain whitespace
        n = n.join(' ') if n.is_a? Array
        self[:name] = n
      end

      def <<(arg)
        raise InvalidChildError, "A Voice can only accept String, Audio, Break, Emphasis, Mark, P, Phoneme, Prosody, SayAs, Sub, S, Voice as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :language, :gender, :age, :variant, :name
      end
    end # Voice
  end # SSML
end # RubySpeech
