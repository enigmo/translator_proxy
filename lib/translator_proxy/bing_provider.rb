require 'rexml/document'

module TranslatorProxy
  class BingProvider
    class<<self
      attr_accessor :default_options
    end

    # http://docs.microsofttranslator.com/oauth-token.html
    ACCESS_TOKEN_URL = 'https://api.cognitive.microsoft.com/sts/v1.0/issueToken'

    TRANSLATE_METHOD_URL       = "http://api.microsofttranslator.com/v2/HTTP.svc/Translate"
    TRANSLATE_ARRAY_METHOD_URL = "http://api.microsofttranslator.com/V2/Http.svc/TranslateArray"

    SCHEMAS_SERVICE_V2 = "http://schemas.datacontract.org/2004/07/Microsoft.MT.Web.Service.V2"
    SCHEMAS_ARRAY      = "http://schemas.microsoft.com/2003/10/Serialization/Arrays"

    self.default_options = {
      subscription_key: nil
    }

    attr_reader :options

    def default_options
      self.class.default_options
    end

    def initialize(options={})
      @options = options.merge!(
        subscription_key: options[:subscription_key] || default_options[:subscription_key]
      )
      @token_expires_at = Time.now
      fail 'required parameters :subscription_key' unless @options.key?(:subscription_key)
    end

    # Translate Method : https://msdn.microsoft.com/en-us/library/ff512406.aspx
    def translate(text, opts = {})
      headers = build_headers
      params = build_params(text, opts)
      resp = get(TRANSLATE_METHOD_URL, headers: headers, params: params)

      doc = REXML::Document.new(resp.body)
      doc.elements['string'].text
    end

    def translate_bulk(texts, opts = {})
      headers = build_headers
      body = build_body(texts, opts)
      resp = post(TRANSLATE_ARRAY_METHOD_URL, headers: headers, body: body)

      doc = REXML::Document.new(resp.body)
      doc.root.children.map do |translate_array_response|
        translate_array_response.elements['TranslatedText'].text
      end
    end

    private

    def token
      request_token if expire_token?
      @token
    end

    def expire_token?
      @token_expires_at < Time.now
    end

    def request_token
      uri = URI(ACCESS_TOKEN_URL)
      req = Net::HTTP::Post.new(uri)
      req['Ocp-Apim-Subscription-Key'] = options[:subscription_key]
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
      fail res.body if res.code != '200'
      @token = res.body
      @token_expires_at = Time.now + (5 * 60) # expire token in 5 minutes
    end

    def build_params(text, opts={})
      {
        :text => text,
        :from => opts[:from] || 'ja',
        :to   => opts[:to]   || 'en'
      }
    end

    def build_headers
      {
        "Authorization" => "Bearer #{token}",
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

    def get(url, headers:, params:)
      uri = URI(url)
      uri.query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new(uri)
      headers.each do |key, value|
        req[key] = value
      end
      Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
    end

    def post(url, headers:, body:)
      uri = URI(url)
      req = Net::HTTP::Post.new(uri)
      req.body = body
      headers.each do |key, value|
        req[key] = value
      end
      Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
    end
  end
end
