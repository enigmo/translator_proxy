[![Circle CI](https://circleci.com/gh/enigmo/translator_proxy/tree/master.svg?style=svg)](https://circleci.com/gh/enigmo/translator_proxy/tree/master)
[![Code Climate](https://codeclimate.com/github/enigmo/translator_proxy/badges/gpa.svg)](https://codeclimate.com/github/enigmo/translator_proxy)

# TranslatorProxy

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'translator_proxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install translator_proxy

## Usage

### Translate on Command-line

```ruby
require 'translator_proxy'

# get client-id and client-secret from microsoft
provider_info = {
    client_id: 'client-id',
    client_secret: 'client-secret'
  }

# create translate provider (only Bing now)
TranslatorProxy.provider = ::TranslatorProxy::BingProvider.new(provider_info)

# translate languages
options = { from: 'ja', to: 'en' }

# Translate a string text
text = 'こんにちは'  # Japanese.
TranslatorProxy.translate(text, options)  # => "Hello"

# Translate string array
texts = ['おはよう', 'こんにちは']  # Japanese.
TranslatorProxy.translate_bulk(texts, options)  # => ['Good morning', 'Hello']
```

### Translate on Server

TODO: Write usage instructions from server here

## Contributing

1. Fork it ( http://github.com/<my-github-username>/translator_proxy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
