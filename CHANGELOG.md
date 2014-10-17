# [develop](https://github.com/benlangfeld/ruby_speech)
  * Bugfix: Rulerefs referenced n-levels deep under Rulerefs should be expanded.

# [2.3.2](https://github.com/benlangfeld/ruby_speech/compare/v2.3.1...v2.3.2) - [2014-04-21](https://rubygems.org/gems/ruby_speech/versions/2.3.2)
  * Bugfix: String nodes should take non-strings and cast to a string (`#to_s`)
  * Bugfix: Cleanly handle NLSML with no input tag
  * Bugfix: Drawing an NLSML doc should return something structured/parsed
  * Bugfix: Cloning SSML documents no longer turns them into GRXML docs

# [2.3.1](https://github.com/benlangfeld/ruby_speech/compare/v2.3.0...v2.3.1) - [2014-02-24](https://rubygems.org/gems/ruby_speech/versions/2.3.1)
  * Bugfix: Phone number grammar should only allow a single instance of '*'/'x'
  * Bugfix: Concatenating documents containing strings across the border inserts appropriate spacing (#21).

# [2.3.0](https://github.com/benlangfeld/ruby_speech/compare/v2.2.2...v2.3.0) - [2013-09-30](https://rubygems.org/gems/ruby_speech/versions/2.3.0)
  * Feature: Allow generation of a boolean, date, digits, currency, number, phone or time grammar including from URIs
  * Bugfix: Ensure that rule refs can be reused when inlining grammars

# [2.2.2](https://github.com/benlangfeld/ruby_speech/compare/v2.2.1...v2.2.2) - [2013-09-03](https://rubygems.org/gems/ruby_speech/versions/2.2.2)
  * Bugfix: Fix an exception message to include object type

# [2.2.1](https://github.com/benlangfeld/ruby_speech/compare/v2.2.0...v2.2.1) - [2013-07-02](https://rubygems.org/gems/ruby_speech/versions/2.2.1)
  * Bugfix: Ensure that concatenating documents doesn't mutate the originals on JRuby

# [2.2.0](https://github.com/benlangfeld/ruby_speech/compare/v2.1.2...v2.2.0) - [2013-06-26](https://rubygems.org/gems/ruby_speech/versions/2.2.0)
  * Bugfix: Constant autoload in rbx C extensions doesn't work properly
  * Bugfix: No longer subclass or copy nodes, use delegation instead
  * Bugfix: Java 1.6 compatability
  * CS: Remove niceogiri dependency
  * CS: Remove autoloading
  * CS: Depend on activesupport less

# [2.1.2](https://github.com/benlangfeld/ruby_speech/compare/v2.1.1...v2.1.2) - [2013-06-05](https://rubygems.org/gems/ruby_speech/versions/2.1.2)
  * Bugfix: Allow wrapping a pre-parsed XML node nested arbitrary deeply as an NLSML document

# [2.1.1](https://github.com/benlangfeld/ruby_speech/compare/v2.1.0...v2.1.1) - [2013-05-09](https://rubygems.org/gems/ruby_speech/versions/2.1.1)
  * Bugfix: Support numeric SISR literal tags

# [2.1.0](https://github.com/benlangfeld/ruby_speech/compare/v2.0.2...v2.1.0) - [2013-05-07](https://rubygems.org/gems/ruby_speech/versions/2.1.0)
  * Feature: Support for SISR literal syntax

# [2.0.2](https://github.com/benlangfeld/ruby_speech/compare/v2.0.1...v2.0.2) - [2013-05-01](https://rubygems.org/gems/ruby_speech/versions/2.0.2)
  * Bugfix: Differentiate between GRXML match cases with are and are not maximal
    * A Match can accept further input while still matching, while a a MaxMatch cannot.
    * Matching implementation moved down to C/Java to avoid repeated regex compilation and confusing jumping about.
  * Bugfix: Back to functioning on JRuby with latest Nokogiri release

# [2.0.1](https://github.com/benlangfeld/ruby_speech/compare/v2.0.0...v2.0.1) - [2013-04-27](https://rubygems.org/gems/ruby_speech/versions/2.0.1)
  * Bugfix: Build native C extension in the correct location

# [2.0.0](https://github.com/benlangfeld/ruby_speech/compare/v1.1.0...v2.0.0) - [2013-04-27](https://rubygems.org/gems/ruby_speech/versions/2.0.0)
  * Change: Comply with MRCPv2 flavour of NLSML
    * Confidence is now a float in the XML representation
    * Models are no longer used
    * XForms no longer used
    * Now have a true namespace
    * Instance is in the NLSML namespace
    * Must support string instances
  * Change: Grammar matching now uses a Matcher rather than directly on the Grammar element
  * Feature: Grammar matching now uses native C/Java regexes with PCRE/java.util.regex for clean partial matching and SPEEEEEED
  * Bugfix: Item repeats now work correctly

# [1.1.0](https://github.com/benlangfeld/ruby_speech/compare/v1.0.2...v1.1.0) - [2013-03-02](https://rubygems.org/gems/ruby_speech/versions/1.1.0)
  * Feature: NLSML building & parsing

# [1.0.2](https://github.com/benlangfeld/ruby_speech/compare/v1.0.1...v1.0.2) - [2012-12-26](https://rubygems.org/gems/ruby_speech/versions/1.0.2)
  * Bugfix: Get test suite passing on JRuby

# [1.0.1](https://github.com/benlangfeld/ruby_speech/compare/v1.0.0...v1.0.1) - [2012-10-24](https://rubygems.org/gems/ruby_speech/versions/1.0.1)
  * Bugfix: Don't load rubygems because it is evil
  * Bugfix: Allow setting language (and other) attributes on root of SSML doc when using #draw DSL

# 1.0.0 - 2012-03-13
  * Bump major version because we have a stable API

# 0.5.1 - 2012-01-09
  * Feature: Chaining child injection using #<< now works
  * Feature: Reading the repeat value for a GRXML Item now returns an Integer or a Range, rather than the plain string
  * Feature: Most simple GRXML grammars now return PotentialMatch when the provided input is valid but incomplete. This does not work for complex grammars including repeats and deep nesting. Fixes for these coming soon.

# 0.5.0 - 2012-01-03
  * Feature: Add a whole bunch more SSML elements:
    * p & s
    * mark
    * desc
    * sub
    * phoneme
  * Feature: Added the ability to inline grammar rule references in both destructive and non-destructive modes
  * Feature: Added the ability to tokenize a grammar, turning all tokens into unambiguous `<token/>` elements
  * Feature: Added the ability to whitespace normalize a grammar
  * Feature: Added the ability to match an input string against a Grammar
  * Feature: Constructing a GRXML grammar with a root rule specified but not provided will raise an exception
  * Feature: Embedding a GRXML grammar of a mode different from the host will raise an exception
  * Bugfix: Fix upward traversal through a document via #parent

# 0.4.0 - 2011-12-30
  * Feature: Add the ability to look up child elements by name/attributes easily
  * Feature: Allow easy access to a GRXML grammar's root rule element
  * Feature: Allow inlining a Grammar's rulerefs
  * Bugfix: Ruby 1.8 and JRuby don't do a tree-search for const_defined?
  * Bugfix: Don't try to pass a method call up to the DSL block binding if it doesn't respond to the method either

# 0.3.4
  * Eager-autoload all elements so that importing will work with elements that havn't been used yet directly
  * Allow using the DSL with method calls out of the block
  * Fix inspection/comparison of some elements that don't have a language attribute

# 0.3.3
  * Allow `SSML::Element.import` and `GRXML::Element.import` to take a string as well as a Nokogiri::XML::Node
  * Allow importing GRXML/SSML documents via their respective modules (eg `RubySpeech::GRXML.import '<grammar ... />'`)

# 0.3.2
  * Fix inheriting an `SSML::Speak`'s language. Previously an imported `<speak/>` would end up with a `lang` attribute in addition to `xml:lang`, and `xml:lang` would have the default value (`en-US`). This required a Niceogiri dependency update.

# 0.3.1
  * Get the whole test suite passing on Ruby 1.8.7 and JRuby (thanks to Taylor Carpenter!)

# 0.3.0
  * Feature (Taylor Carpenter): Added support for GRXML documents with most elements implemented.

# 0.2.2
  * Feature: The SSML DSL now supports embedding SSML documents, elements or strings via the `embed` method. This behaves as you might expect:

  ```ruby
    doc1 = RubySpeech::SSML.draw do
      string "Hi, I'm Fred. The time is currently "
      say_as :interpret_as => 'date', :format => 'dmy' do
        "01/02/1960"
      end
    end

    doc2 = RubySpeech::SSML.draw do
      voice :gender => :male, :name => 'fred' do
        embed doc1
      end
    end

    doc2.to_s
  ```

  ```xml
    <speak xmlns="http://www.w3.org/2001/10/synthesis" version="1.0" xml:lang="en-US">
      <voice gender="male" name="fred">
        Hi, I'm Fred. The time is currently
        <say-as interpret-as="date" format="dmy">
          01/02/1960
        </say-as>
      </voice>
    </speak>
  ```

# 0.2.1
  * Bugfix: SSML element's children now include any text content, and text content is copied when importing/concatenating documents

# 0.2.0
  * API Change: SSML::SayAs.new (and the DSL method `say_as`) now take `:interpret_as` in the options hash, rather than a separate first argument. This is for consistency with the other element types.
  * Feature: SSML elements can now be imported from a Nokogiri Node or a string
  * Feature: SSML elements now respond to #children with an array of SSML elements, rather than a Nokogiri NodeSet
  * Bugfix/Feature: Comparing SSML elements now compares children

# 0.1.5
  * Feature: Now added support for SSML `<audio/>`

# 0.1.4
  * Bugfix: Speak#+ now returns a brand new Speak rather than modifying the original object
  * Bugfix: Speak#+ now re-sets the namespace on child elements to ensure no default namespace prefix is added

# 0.1.3
  * Bugfix: Strings included via the DSL (both as a block return value and by calling #string) are now properly escaped

# 0.1.2
  * API Change: SSML.draw now returns a Speak
  * Feature: Speak objects can be turned into an XML document using #to_doc
  * Feature: Speak objects can now be concatenated such that children are merged together

# 0.1.1
  * Bugfix: DSL now allows for nesting all allowed elements within each other

# 0.1.0
  * Initial Release
