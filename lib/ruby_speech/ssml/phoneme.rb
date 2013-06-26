require 'ruby_speech/ssml/element'

module RubySpeech
  module SSML
    ##
    # The phoneme element provides a phonemic/phonetic pronunciation for the contained text. The phoneme element may be empty. However, it is recommended that the element contain human-readable text that can be used for non-spoken rendering of the document. For example, the content may be displayed visually for users with hearing impairments.
    #
    # The ph attribute is a required attribute that specifies the phoneme/phone string.
    #
    # This element is designed strictly for phonemic and phonetic notations and is intended to be used to provide pronunciations for words or very short phrases. The phonemic/phonetic string does not undergo text normalization and is not treated as a token for lookup in the lexicon (see Section 3.1.4), while values in say-as and sub may undergo both. Briefly, phonemic strings consist of phonemes, language-dependent speech units that characterize linguistically significant differences in the language; loosely, phonemes represent all the sounds needed to distinguish one word from another in a given language. On the other hand, phonetic strings consist of phones, speech units that characterize the manner (puff of air, click, vocalized, etc.) and place (front, middle, back, etc.) of articulation within the human vocal tract and are thus independent of language; phones represent realized distinctions in human speech production.
    #
    # The alphabet attribute is an optional attribute that specifies the phonemic/phonetic alphabet. An alphabet in this context refers to a collection of symbols to represent the sounds of one or more human languages. The only valid values for this attribute are "ipa" (see the next paragraph) and vendor-defined strings of the form "x-organization" or "x-organization-alphabet". For example, the Japan Electronics and Information Technology Industries Association [JEITA] might wish to encourage the use of an alphabet such as "x-JEITA" or "x-JEITA-2000" for their phoneme alphabet [JEIDAALPHABET].
    #
    # Synthesis processors should support a value for alphabet of "ipa", corresponding to Unicode representations of the phonetic characters developed by the International Phonetic Association [IPA]. In addition to an exhaustive set of vowel and consonant symbols, this character set supports a syllable delimiter, numerous diacritics, stress symbols, lexical tone symbols, intonational markers and more. For this alphabet, legal ph values are strings of the values specified in Appendix 2 of [IPAHNDBK]. Informative tables of the IPA-to-Unicode mappings can be found at [IPAUNICODE1] and [IPAUNICODE2]. Note that not all of the IPA characters are available in Unicode. For processors supporting this alphabet,
    #
    # * The processor must syntactically accept all legal ph values.
    # * The processor should produce output when given Unicode IPA codes that can reasonably be considered to belong to the current language.
    # * The production of output when given other codes is entirely at processor discretion.
    #
    # It is an error if a value for alphabet is specified that is not known or cannot be applied by a synthesis processor. The default behavior when the alphabet attribute is left unspecified is processor-specific.
    #
    # The phoneme element itself can only contain text (no elements).
    #
    # http://www.w3.org/TR/speech-synthesis/#S3.1.9
    #
    class Phoneme < Element

      register :phoneme

      VALID_CHILD_TYPES = [Nokogiri::XML::Text, String].freeze

      ##
      # Specifies the phonemic/phonetic alphabet
      #
      # @return [String]
      #
      def alphabet
        read_attr :alphabet
      end

      ##
      # @param [String] other the phonemic/phonetic alphabet
      #
      def alphabet=(other)
        self[:alphabet] = other
      end

      ##
      # Specifies the phoneme/phone string.
      #
      # @return [String]
      #
      def ph
        read_attr :ph
      end

      ##
      # @param [String] other the phoneme/phone string.
      #
      def ph=(other)
        self[:ph] = other
      end

      def <<(arg)
        raise InvalidChildError, "A Phoneme can only accept Strings as children" unless VALID_CHILD_TYPES.include? arg.class
        super
      end

      def eql?(o)
        super o, :alphabet, :ph
      end
    end # Phoneme
  end # SSML
end # RubySpeech
