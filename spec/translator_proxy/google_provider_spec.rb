# encoding: UTF-8
require 'spec_helper'

describe TranslatorProxy::GoogleProvider do
  let(:provider) { TranslatorProxy::GoogleProvider.new(init_options) }
  let(:init_options) { { project: 'test-project', keyfile: 'test-keyfile.json' } }
  let(:options) { { from: 'ja', to: 'en', model: 'nmt' } }
  let(:mock_client) do
    client = double('client')
    allow(client).to receive(:translate).and_return(dummy_translation)
    client
  end

  before { allow(provider).to receive(:client).and_return(mock_client) }

  describe '#translate' do
    let(:text) { 'こんにちは' }
    let(:dummy_translation) { double('translation', text: 'Hello') }

    it 'should return translated text' do
      translated_text = provider.translate(text, options)
      expect(translated_text).to eq 'Hello'
    end
  end

  describe '#translate_bulk' do
    let(:texts) { %w(おはよう こんにちは こんばんは) }
    let(:dummy_translation) do
      ['Good morning', 'Hello', 'Good evening'].map do |text|
        double('translation', text: text)
      end
    end

    it 'should return translated texts' do
      translated_texts = provider.translate_bulk(texts, options)
      expect(translated_texts).to eq ['Good morning', 'Hello', 'Good evening']
    end
  end
end
