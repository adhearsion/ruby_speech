[![Gem Version](https://badge.fury.io/rb/ruby_speech.png)](https://rubygems.org/gems/ruby_speech)
[![Build Status](https://secure.travis-ci.org/adhearsion/ruby_speech.png?branch=develop)](http://travis-ci.org/adhearsion/ruby_speech)
[![Dependency Status](https://gemnasium.com/adhearsion/ruby_speech.png?travis)](https://gemnasium.com/adhearsion/ruby_speech)
[![Code Climate](https://codeclimate.com/github/adhearsion/ruby_speech.png)](https://codeclimate.com/github/adhearsion/ruby_speech)
[![Coverage Status](https://coveralls.io/repos/adhearsion/ruby_speech/badge.png?branch=develop)](https://coveralls.io/r/adhearsion/ruby_speech)

# RubySpeech
RubySpeech is a library for constructing and parsing Text to Speech (TTS) and Automatic Speech Recognition (ASR) documents such as [SSML](http://www.w3.org/TR/speech-synthesis), [GRXML](http://www.w3.org/TR/speech-grammar/) and [NLSML](http://www.w3.org/TR/nl-spec/). Such documents can be constructed to be processed by TTS and ASR engines, parsed as the result from such, or used in the implementation of such engines.

## Dependencies

### pcre (except on JRuby)

#### On OSX with Homebrew
```
brew install pcre
```

#### On Ubuntu/Debian
```
sudo apt-get install libpcre3 libpcre3-dev
```

#### On CentOS
```
sudo yum install pcre-devel
```

## Installation
    gem install ruby_speech

## Ruby Version Compatability
  * CRuby 1.9.3+ (1.9.2 is unofficially supported, but not regularly tested)
  * JRuby 1.7+

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

#### Built-in grammars

There are some grammars pre-defined which are available from the `RubySpeech::GRXML::Builtins` module like so:

```ruby
require 'ruby_speech'

RubySpeech::GRXML::Builtins.currency
```

which yields

```xml
<grammar xmlns="http://www.w3.org/2001/06/grammar" version="1.0" xml:lang="en-US" mode="dtmf" root="currency">
  <rule id="currency" scope="public">
    <item repeat="0-">
      <ruleref uri="#digit"/>
    </item>
    <item>*</item>
    <item repeat="2">
      <ruleref uri="#digit"/>
    </item>
  </rule>
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
</grammar>
```

These grammars come from the VoiceXML specification, and can be used as indicated there (including parameterisation). They can be used just like any you would manually create, and there's nothing special about them except that they are already defined for you. A full list of available grammars can be found in [the API documentation](http://rubydoc.info/gems/ruby_speech/RubySpeech/GRXML/Builtins).

These grammars are also available via URI like so:

```ruby
require 'ruby_speech'

RubySpeech::GRXML.from_uri('builtin:dtmf/boolean?y=3;n=4')
```

#### Grammar matching

It is possible to match some arbitrary input against a GRXML grammar, like so:

```ruby
require 'ruby_speech'

>> grammar = RubySpeech::GRXML.draw mode: :dtmf, root: 'pin' do
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

matcher = RubySpeech::GRXML::Matcher.new grammar

>> matcher.match '*9'
=> #<RubySpeech::GRXML::Match:0x00000100ae5d98
      @mode = :dtmf,
      @confidence = 1,
      @utterance = "*9",
      @interpretation = "*9"
    >
>> matcher.match '1234#'
=> #<RubySpeech::GRXML::Match:0x00000100b7e020
      @mode = :dtmf,
      @confidence = 1,
      @utterance = "1234#",
      @interpretation = "1234#"
    >
>> matcher.match '5678#'
=> #<RubySpeech::GRXML::Match:0x00000101218688
      @mode = :dtmf,
      @confidence = 1,
      @utterance = "5678#",
      @interpretation = "5678#"
    >
>> matcher.match '1111#'
=> #<RubySpeech::GRXML::Match:0x000001012f69d8
      @mode = :dtmf,
      @confidence = 1,
      @utterance = "1111#",
      @interpretation = "1111#"
    >
>> matcher.match '111'
=> #<RubySpeech::GRXML::NoMatch:0x00000101371660>
```

### NLSML

[Natural Language Semantics Markup Language](http://tools.ietf.org/html/draft-ietf-speechsc-mrcpv2-27#section-6.3.1) is the format used by many Speech Recognition engines and natural language processors to add semantic information to human language. RubySpeech is capable of generating and parsing such documents.

It is possible to generate an NLSML document like so:

```ruby
require 'ruby_speech'

nlsml = RubySpeech::NLSML.draw grammar: 'http://flight' do
  interpretation confidence: 0.6 do
    input "I want to go to Pittsburgh", mode: :voice

    instance do
      airline do
        to_city 'Pittsburgh'
      end
    end
  end

  interpretation confidence: 0.4 do
    input "I want to go to Stockholm"

    instance do
      airline do
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
<result xmlns="http://www.ietf.org/xml/ns/mrcpv2" grammar="http://flight">
  <interpretation confidence="0.6">
    <input mode="voice">I want to go to Pittsburgh</input>
    <instance>
      <airline>
        <to_city>Pittsburgh</to_city>
      </airline>
    </instance>
  </interpretation>
  <interpretation confidence="0.4">
    <input>I want to go to Stockholm</input>
    <instance>
      <airline>
        <to_city>Stockholm</to_city>
      </airline>
    </instance>
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
        input: { mode: :voice, content: 'I want to go to Pittsburgh' },
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
          input: { mode: :voice, content: 'I want to go to Pittsburgh' },
          instance: { airline: { to_city: 'Pittsburgh' } }
        }
```

Check out the [YARD documentation](http://rdoc.info/github/adhearsion/ruby_speech/master/frames) for more

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
* [Source](https://github.com/adhearsion/ruby_speech)
* [Documentation](http://rdoc.info/gems/ruby_speech/frames)
* [Bug Tracker](https://github.com/adhearsion/ruby_speech/issues)
* [CI](https://travis-ci.org/#!/adhearsion/ruby_speech)

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  * If you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2013 Ben Langfeld. MIT licence (see LICENSE for details).
