require 'oj'

module TranslatorProxy
  class BaiduProvider
    HTTP_API_URL = 'http://api.fanyi.baidu.com/api/trans/vip/translate'

    attr_reader :app_id, :secret_key

    def initialize(options={})
      fail 'required parameters :app_id' unless options.key?(:app_id)
      fail 'required parameters :secret_key' unless options.key?(:secret_key)
      @app_id = options[:app_id]
      @secret_key = options[:secret_key]
    end

    def translate(text, opts = {})
      params = build_params(text, opts)
      response = get(HTTP_API_URL, params)
      # NOTE: join("\n") each results. Because baidu api translate "\n" as other sentences.
      # Ex) "おはよう\nこんにちは" =>
      #     {"trans_result" => [{"src"=>"おはよう", "dst"=>"good morning"},{"src"=>"こんにちは", "dst"=>"hello"}]}
      response['trans_result'].map { |result| result['dst'] }.join("\n")
    end

    def translate_bulk(texts, opts = {})
      texts.map do |text|
        translate(text, opts)
      end
    end

    private

    def build_params(text, opts={})
      {
        appid: app_id,
        q: text,
        from: opts[:from] || :ja,
        to:   opts[:to]   || :en,
        salt: salt,
        sign: sign(text)
      }
    end

    def salt
      @salt ||= Random.rand(32768..65536)
    end

    # how to generate sign
    # see http://api.fanyi.baidu.com/api/trans/product/apidoc
    def sign(text)
      Digest::MD5.hexdigest([app_id, text, salt, secret_key].join)
    end

    def get(url, params)
      uri = URI(url)
      uri.query = URI.encode_www_form(params)
      req = Net::HTTP::Get.new(uri)
      res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
      Oj.load(res.body)
    end
  end
end
