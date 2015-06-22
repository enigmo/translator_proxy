require 'oauth2'
require 'rexml/document'

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

  class BingProvider
    class<<self
      attr_accessor :default_options
    end

    TRANSLATE_METHOD_URL       = "http://api.microsofttranslator.com/v2/HTTP.svc/Translate"
    TRANSLATE_ARRAY_METHOD_URL = "http://api.microsofttranslator.com/V2/Http.svc/TranslateArray"

    SCHEMAS_SERVICE_V2 = "http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2"
    SCHEMAS_ARRAY      = "http://schemas.microsoft.com/2003/10/Serialization/Arrays"

    self.default_options = {
      :site           => 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13',
      :scope          => 'http://api.microsofttranslator.com',
      # Ajax response comes with BOM and double quotes "\xEF\xBB\xBF\"Japanese\""
      # :translator_url => 'http://api.microsofttranslator.com/v2/Ajax.svc/Translate',
      :client_id      => nil,
      :client_secret  => nil
    }

    attr_reader :options

    def default_options
      self.class.default_options
    end

    def initialize(options={})
      @options = options.merge!(
        :site          => options[:site]          || default_options[:site],
        :scope         => options[:scope]         || default_options[:scope],
        :client_id     => options[:client_id]     || default_options[:client_id],
        :client_secret => options[:client_secret] || default_options[:client_secret]
      )
      fail 'required parameters :client_id/:client_secret' unless @options.key?(:client_id) || @options.key?(:client_secret)
    end

    # Translate Method : https://msdn.microsoft.com/en-us/library/ff512406.aspx
    def translate(text, opts = {})
      get_token if !@token || @token.expired?
      params = build_params(text, opts)
      resp = @token.get(TRANSLATE_METHOD_URL, :params => params)

      doc = REXML::Document.new(resp.body)
      doc.elements['string'].text
    end

    # TranslateArray Method: https://msdn.microsoft.com/ja-jp/library/ff512422.aspx#phpexample
    def translate_bulk(texts, opts = {})
      get_token if !@token || @token.expired?
      body = build_body(texts, opts)
      resp = @token.post(TRANSLATE_ARRAY_METHOD_URL, headers: headers, body: body)

      doc = REXML::Document.new(resp.body)
      doc.root.children.map do |translate_array_response|
        translate_array_response.elements['TranslatedText'].text
        translate_array_response.elements['TranslatedText'].text
      end
    end

    private

    # rubocop:disable AccessorMethodName
    def get_token
      @token = client.client_credentials.get_token(
        {:scope => 'http://api.microsofttranslator.com'},
        'auth_scheme' => 'request_body')
    end
    # rubocop:enable AccessorMethodName

    def build_params(text, opts={})
      {
        :text => text,
        :from => opts[:from] || 'ja',
        :to   => opts[:to]   || 'en'
      }
    end

    def headers
      {
        "Authorization" => "Bearer#{options[:client_secret]}",
        'Content-type'=> 'application/xml'
      }
    end

    def build_body(texts, opts={})
      doc = REXML::Document.new('<TranslateArrayRequest/>')

      root = doc.root
      root.add_element('AppId')
      root.add_element('From').add_text(opts[:from] || 'ja')

      options_el = root.add_element('Options')
      options_el.add_element('ContentType', 'xmlns' => SCHEMAS_SERVICE_V2).add_text('text/html')

      texts_el = root.add_element('Texts')
      texts.each do |text|
        texts_el.add_element('string', 'xmlns' => SCHEMAS_ARRAY).add_text(text)
      end

      root.add_element('To').add_text(opts[:to] || 'en')

      doc.root.to_s
    end

    def client
      @client ||= ::OAuth2::Client.new(options[:client_id],
                                       options[:client_secret],
                                       :site => options[:site],
                                       :token_url =>  nil)
    end
  end
end

TranslatorProxy.provider = ::TranslatorProxy::BingProvider.new
