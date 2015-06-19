require 'spec_helper'
require_relative '../../lib/translator_proxy/server'


describe 'Server Service' do
  include Rack::Test::Methods

  def app
    TranslatorProxy::Server
  end

  # NOTE: if you want to test with real ms api service,
  #       please get client_id and client_secret from ms,
  #       replace text below and remove VCR.use_cassette methods.
  let(:provider_info) do
    {
      client_id: 'foobar',
      client_secret: 'hogehoge'
    }
  end


  before do
    TranslatorProxy.provider = ::TranslatorProxy::BingProvider.new(provider_info)
  end

  it 'should return a translated text json' do
    url = URI.encode '/?text=こんにちは&from=ja&to=en'
    VCR.use_cassette 'translate_server_response' do
      get url
      expect(last_response).to be_ok
      expect(last_response.body).to eq "{\"result\":\"Hello\"}"
    end
  end

  it 'should return a translated text json' do
    url = URI.encode '/bulk'
    params = {
      texts: %w(おはよう こんにちは こんばんは),
      from:  'ja',
      to:    'en'
    }
    VCR.use_cassette 'translate_bulk_server_response' do
      post url, params
      expect(last_response).to be_ok
      expect(last_response.body).to eq "{\"result\":[\"Good morning\",\"Hello\",\"Good evening\"]}"
    end
  end
end
