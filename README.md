# RubySpeech
RubySpeech is a library for constructing and parsing Text to Speech (TTS) and Automatic Speech Recognition (ASR) documents such as [SSML](http://www.w3.org/TR/speech-synthesis), [GRXML](http://www.w3.org/TR/speech-grammar/) and [NLSML](http://www.w3.org/TR/nl-spec/). Such documents can be constructed to be processed by TTS and ASR engines, parsed as the result from such, or used in the implementation of such engines.

## Installation
    gem install ruby_speech

## Library

### SSML
RubySpeech provides a DSL for constructing SSML documents like so:

```ruby
require 'ruby_speech'

speak = RubySpeech::SSML.draw do
  voice gender: :male, name: 'fred' do
    string "Hi, I'm Fred. The time is currently "
    say_as interpret_as: 'date', format: 'dmy' do
      "01/02/1960"
    end
  end
end

speak.to_s
```

becomes:

```xml
<speak xmlns="http://www.w3.org/2001/10/synthesis" version="1.0" xml:lang="en-US">
  <voice gender="male" name="fred">
    Hi, I'm Fred. The time is currently <say-as format="dmy" interpret-as="date">01/02/1960</say-as>
  </voice>
</speak>
```

Once your `Speak` is fully prepared and you're ready to send it off for processing, you must call `to_doc` on it to add the XML header:

```xml
<?xml version="1.0"?>
<speak xmlns="http://www.w3.org/2001/10/synthesis" version="1.0" xml:lang="en-US">
  <voice gender="male" name="fred">
    Hi, I'm Fred. The time is currently <say-as format="dmy" interpret-as="date">01/02/1960</say-as>
  </voice>
</speak>
```

You may also then need to call `to_s`.

### GRXML

Construct a GRXML (SRGS) document like this:

```ruby
require 'ruby_speech'

grammy = RubySpeech::GRXML.draw mode: :dtmf, root: 'pin' do
  rule id: 'digit' do
    one_of do
      ('0'..'9').map { |d| item { d } }
    end
  end

  rule id: 'pin', scope: 'public' do
    one_of do
      item do
        item repeat: '4' do
          ruleref uri: '#digit'
        end
        "#"
      end
      item do
        "* 9"
      end
    end
  end
end

grammy.to_s
```

which becomes

```xml
<grammar xmlns="http://www.w3.org/2001/06/grammar" version="1.0" xml:lang="en-US" mode="dtmf" root="pin">
  <rule id="digit">
    <one-of>
      <item>0</item>
      <item>1</item>
      <item>2</item>
      <item>3</item>
      <item>4</item>
      <item>5</item>
      <item>6</item>
      <item>7</item>
      <item>8</item>
      <item>9</item>
    </one-of>
  </rule>
  <rule id="pin" scope="public">
    <one-of>
      <item><item repeat="4"><ruleref uri="#digit"/></item>#</item>
      <item>* 9</item>
    </one-of>
  </rule>
</grammar>
```

#### Grammar matching

It is possible to match some arbitrary input against a GRXML grammar. In order to do so, certain normalization routines should first be run on the grammar in order to prepare it for matching. These are reference inlining, tokenization and whitespace normalization, and are described [in the SRGS spec](http://www.w3.org/TR/speech-grammar/#S2.1). This process will transform the above grammar like so:

```ruby
grammy.inline!
grammy.tokenize!
grammy.normalize_whitespace
```

```xml
<grammar xmlns="http://www.w3.org/2001/06/grammar" version="1.0" xml:lang="en-US" mode="dtmf" root="pin">
  <rule id="pin" scope="public">
    <one-of>
      <item>
        <item repeat="4">
          <one-of>
            <item>
              <token>0</token>
            </item>
            <item>
              <token>1</token>
            </item>
            <item>
              <token>2</token>
            </item>
            <item>
              <token>3</token>
            </item>
            <item>
              <token>4</token>
            </item>
            <item>
              <token>5</token>
            </item>
            <item>
              <token>6</token>
            </item>
            <item>
              <token>7</token>
            </item>
            <item>
              <token>8</token>
            </item>
            <item>
              <token>9</token>
            </item>
          </one-of>
        </item>
        <token>#</token>
      </item>
      <item>
        <token>*</token>
        <token>9</token>
      </item>
    </one-of>
  </rule>
</grammar>
```

Matching against some sample input strings then returns the following results:

```ruby
>> subject.match '*9'
=> #<RubySpeech::GRXML::Match:0x00000100ae5d98
      @mode = :dtmf,
      @confidence = 1,
      @utterance = "*9",
      @interpretation = "*9"
    >
>> subject.match '1234#'
=> #<RubySpeech::GRXML::Match:0x00000100b7e020
      @mode = :dtmf,
      @confidence = 1,
      @utterance = "1234#",
      @interpretation = "1234#"
    >
>> subject.match '5678#'
=> #<RubySpeech::GRXML::Match:0x00000101218688
      @mode = :dtmf,
      @confidence = 1,
      @utterance = "5678#",
      @interpretation = "5678#"
    >
>> subject.match '1111#'
=> #<RubySpeech::GRXML::Match:0x000001012f69d8
      @mode = :dtmf,
      @confidence = 1,
      @utterance = "1111#",
      @interpretation = "1111#"
    >
>> subject.match '111'
=> #<RubySpeech::GRXML::NoMatch:0x00000101371660>
```

### NLSML

[Natural Language Semantics Markup Language](http://www.w3.org/TR/nl-spec/) is the format used by many Speech Recognition engines and natural language processors to add semantic information to human language. RubySpeech is capable of generating and parsing such documents.

It is possible to generate an NLSML document like so:

```ruby
require 'ruby_speech'

nlsml = RubySpeech::NLSML.draw(grammar: 'http://flight', 'xmlns:myApp' => 'foo') do
  interpretation confidence: 0.6 do
    input "I want to go to Pittsburgh", mode: :speech

    model do
      group name: 'airline' do
        string name: 'to_city'
      end
    end

    instance do
      self['myApp'].airline do
        to_city 'Pittsburgh'
      end
    end
  end

  interpretation confidence: 0.4 do
    input "I want to go to Stockholm"

    model do
      group name: 'airline' do
        string name: 'to_city'
      end
    end

    instance do
      self['myApp'].airline do
        to_city "Stockholm"
      end
    end
  end
end

nlsml.to_s
```

becomes:

```xml
<?xml version="1.0"?>
<result xmlns:myApp="foo" xmlns:xf="http://www.w3.org/2000/xforms" grammar="http://flight">
  <interpretation confidence="60">
    <input mode="speech">I want to go to Pittsburgh</input>
    <xf:model>
      <xf:group name="airline">
        <xf:string name="to_city"/>
      </xf:group>
    </xf:model>
    <xf:instance>
      <myApp:airline>
        <myApp:to_city>Pittsburgh</myApp:to_city>
      </myApp:airline>
    </xf:instance>
  </interpretation>
  <interpretation confidence="40">
    <input>I want to go to Stockholm</input>
    <xf:model>
      <xf:group name="airline">
        <xf:string name="to_city"/>
      </xf:group>
    </xf:model>
    <xf:instance>
      <myApp:airline>
        <myApp:to_city>Stockholm</myApp:to_city>
      </myApp:airline>
    </xf:instance>
  </interpretation>
</result>
```

It's also possible to parse an NLSML document and extract useful information from it. Taking the above example, one may do:

```ruby
document = RubySpeech.parse nlsml.to_s

document.match? # => true
document.interpretations # => [
      {
        confidence: 0.6,
        input: { mode: :speech, content: 'I want to go to Pittsburgh' },
        instance: { airline: { to_city: 'Pittsburgh' } }
      },
      {
        confidence: 0.4,
        input: { content: 'I want to go to Stockholm' },
        instance: { airline: { to_city: 'Stockholm' } }
      }
    ]
document.best_interpretation # => {
          confidence: 0.6,
          input: { mode: :speech, content: 'I want to go to Pittsburgh' },
          instance: { airline: { to_city: 'Pittsburgh' } }
        }
```

Check out the [YARD documentation](http://rdoc.info/github/benlangfeld/ruby_speech/master/frames) for more

## Features:
### SSML
* Document construction
* `<voice/>`
* `<prosody/>`
* `<emphasis/>`
* `<say-as/>`
* `<break/>`
* `<audio/>`
* `<p/>` and `<s/>`
* `<phoneme/>`
* `<sub/>`

#### Misc
* `<mark/>`
* `<desc/>`

### GRXML
* Document construction
* `<item/>`
* `<one-of/>`
* `<rule/>`
* `<ruleref/>`
* `<tag/>`
* `<token/>`

### NLSML
* Document construction
* Simple data extraction from documents

## TODO:
### SSML
* `<lexicon/>`
* `<meta/>` and `<metadata/>`

### GRXML
* `<meta/>` and `<metadata/>`
* `<example/>`
* `<lexicon/>`

## Links:
* [Source](https://github.com/benlangfeld/ruby_speech)
* [Documentation](http://rdoc.info/github/benlangfeld/ruby_speech/master/frames)
* [Bug Tracker](https://github.com/benlangfeld/ruby_speech/issues)
* [CI](https://travis-ci.org/#!/benlangfeld/ruby_speech)

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  * If you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2011 Ben Langfeld. MIT licence (see LICENSE for details).
