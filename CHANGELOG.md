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
