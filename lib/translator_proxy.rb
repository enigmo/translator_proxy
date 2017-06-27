require 'translator_proxy/version'
require 'translator_proxy/bing_provider'
require 'translator_proxy/google_provider'

module TranslatorProxy
  class <<self
    attr_accessor :provider

    def translate(text, opts={})
      provider.translate(text, opts)
    end

    def translate_bulk(texts, opts={})
      provider.translate_bulk(texts, opts)
    end
  end
end

# default provider
TranslatorProxy.provider = ::TranslatorProxy::BingProvider.new
