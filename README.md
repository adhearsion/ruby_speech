RubySpeech
--------



Installation
============
    gem install ruby_speech

Library
=======
RubySpeech provides a DSL for constructing SSML documents like so:

```ruby
require 'ruby_speech'

RubySpeech::SSML.draw do
  voice gender: :male, name: 'fred' do
    text "Hi, I'm Fred. The time is currently "
    say_as 'date', format: 'dmy' do
      "01/02/1960"
    end
  end
end
```

becomes:

```xml
<speak xmlns="http://www.w3.org/2001/10/synthesis" version="1.0" xml:lang="en-US">
  <voice gender="male" name="fred">
    Hi, I'm Fred. The time is currently <say-as interpret-as="date" format="dmy">01/02/1960</say-as>
  </voice>
</speak>
```


Check out the [YARD documentation](http://rdoc.info/github/benlangfeld/ruby_speech/develop/frames) for more


Note on Patches/Pull Requests
-----------------------------

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  * If you want to have your own version, that is fine but bump version in a commit by itself so I can ignore when I pull
* Send me a pull request. Bonus points for topic branches.

Copyright
---------

Copyright (c) 2011 Ben Langfeld. MIT licence (see LICENSE for details).
