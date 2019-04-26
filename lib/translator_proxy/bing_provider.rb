
module TranslatorProxy
  class BingProvider
    class<<self
      attr_accessor :default_options
    end

    # http://docs.microsofttranslator.com/oauth-token.html
    ACCESS_TOKEN_URL = 'https://api.cognitive.microsoft.com/sts/v1.0/issueToken'

    # https://docs.microsoft.com/en-us/azure/cognitive-services/translator/quickstart-ruby-translate
    TRANSLATE_V3_METHOD_URL = "https://api.cognitive.microsofttranslator.com"

    self.default_options = {
      subscription_key: nil
    }

    attr_reader :options

    def default_options
      self.class.default_options
    end

    def initialize(options = {})
      @options = options.merge!(
        subscription_key: options[:subscription_key] || default_options[:subscription_key]
      )
      @token_expires_at = Time.now
      fail 'required parameters :subscription_key' unless @options.key?(:subscription_key)
    end

    # Translate Method : https://msdn.microsoft.com/en-us/library/ff512406.aspx
    def translate(texts, opts = {})
      headers = build_headers
      params = build_params(opts)
      body = build_body(texts)
      resp = post(TRANSLATE_V3_METHOD_URL, headers: headers, params: params, body: body)

      translated_text(resp)
    end

    def translate_bulk(texts, opts = {})
      translate(texts, opts)
    end

    private

    def translated_text(resp)
      response = resp.body.force_encoding("utf-8")
      translated_text = JSON.parse(response)
      translated = translated_text.dup

      result = translated.map do |trans|
        trans["translations"].map do |text|
          text["text"]
        end
      end.flatten

      result = result[0] if translated_text.length == 1
      result
    end

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

    def build_params(opts = {})
      # /translate?api-version=3.0&from=ja&to=en
      from_lang = opts[:from] || 'ja'
      to_lang = opts[:to] || 'en'
      "/translate?api-version=3.0&from=#{from_lang}&to=#{to_lang}"
    end

    def build_headers
      {
        "Authorization" => "Bearer #{token}",
        'Content-type'=> 'application/json'
      }
    end

    def build_body(texts)
      data = []
      if texts.is_a?(Array)
        texts.each do |text|
          data << {'text': text}
        end
      else
        data << {'text': texts} 
      end
      data.to_json
    end

    def post(url, headers:, params:, body:)
      uri = URI(url + params)
      req = Net::HTTP::Post.new(uri)
      req.body = body
      headers.each do |key, value|
        req[key] = value
      end
      Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(req)
      end
    end
  end
end
