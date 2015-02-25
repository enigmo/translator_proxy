require 'oauth2'

module TranslatorProxy
  class <<self
    attr_accessor :provider

    def translate(text, opts={})
      provider.translate(text, opts)
    end
  end

  class BingProvider
    class<<self
      attr_accessor :default_options
    end

    self.default_options = {
      :site           => 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13',
      :scope          => 'http://api.microsofttranslator.com',
      :translator_url => 'http://api.microsofttranslator.com/v2/Ajax.svc/Translate',
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

    # rubocop:disable AccessorMethodName
    def get_token
      @token = client.client_credentials.get_token(
        {:scope => 'http://api.microsofttranslator.com'},
        'auth_scheme' => 'request_body')
    end

    def ready?
      !!@token
    end

    def translate(text, opts={})
      unless ready?
        warn 'you need to generate_token before using api'
        return
      end
      params = build_params(text, opts)
      @token.get(default_options[:translator_url], :params => params)
    end

    def build_params(text, opts={})
      # Translate Method
      # https://msdn.microsoft.com/en-us/library/ff512406.aspx
      {
        :text => text,
        :from => opts.fetch(:from, 'ja'),
        :to   => opts.fetch(:to,   'en')
      }
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
