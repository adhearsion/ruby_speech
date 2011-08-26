# RubySpeech
RubySpeech is a library for constructing and parsing Text to Speech (TTS) and Automatic Speech Recognition (ASR) documents such as [SSML](http://www.w3.org/TR/speech-synthesis) and [GRXML](http://www.w3.org/TR/speech-grammar/). The primary use case is for construction of these documents to be processed by TTS and ASR engines.

## Installation
    gem install ruby_speech

## Library
RubySpeech provides a DSL for constructing SSML documents like so:

```ruby
require 'ruby_speech'

speak = RubySpeech::SSML.draw do
  voice gender: :male, name: 'fred' do
    string "Hi, I'm Fred. The time is currently "
    say_as 'date', format: 'dmy' do
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

## TODO:
### SSML
#### Document Structure
* `<p/>` and `<s/>`
* `<phoneme/>`
* `<sub/>`
* `<lexicon/>`
* `<meta/>` and `<metadata/>`

#### Misc
* `<mark/>`
* `<desc/>`


## Links:
* [Source](https://github.com/benlangfeld/ruby_speech)
* [Documentation](http://rdoc.info/github/benlangfeld/ruby_speech/master/frames)
* [Bug Tracker](https://github.com/benlangfeld/ruby_speech/issues)

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  * If you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2011 Ben Langfeld. MIT licence (see LICENSE for details).
