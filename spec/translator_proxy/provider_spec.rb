# encoding: UTF-8
require 'spec_helper'

describe TranslatorProxy::BingProvider do

  # NOTE: if you want to test with real ms api service,
  #       please get subscription_key from ms,
  #       replace text below and remove VCR.use_cassette methods.
  let(:provider_info) do
    {
      subscription_key: 'foobar',
    }
  end

  let(:options) do
    { from: 'ja', to: 'en' }
  end

  before do
    TranslatorProxy.provider = ::TranslatorProxy::BingProvider.new(provider_info)
  end

  describe '#translate' do
    let(:text) { 'こんにちは' }

    it 'should return translated text' do
      VCR.use_cassette 'translate_response' do
        translated_text = TranslatorProxy.translate(text, options)
        expect(translated_text).to eq 'Hello'
      end
    end
  end

  describe '#translate_bulk' do
    let(:texts) { %w(おはよう こんにちは こんばんは) }

    it 'should return translated texts' do
      VCR.use_cassette 'translate_bulk_response' do
        translated_texts = TranslatorProxy.translate_bulk(texts, options)
        expect(translated_texts).to eq ['Good morning', 'Hello', 'Good evening']
      end
    end
  end

end
