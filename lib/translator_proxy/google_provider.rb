require 'google/cloud/translate'

module TranslatorProxy
  class GoogleProvider
    attr_reader :options

    def initialize(options={})
      fail 'required parameters :project' unless options.key?(:project)
      fail 'required parameters :keyfile' unless options.key?(:keyfile)
      @options = options
    end

    def translate(text, opts = {})
      translation = client.translate(text, opts)
      translation.text
    end

    def translate_bulk(texts, opts = {})
      translations = client.translate(texts, opts)
      translations.map(&:text)
    end

    private

    def client
      @client = Google::Cloud::Translate.new(options)
    end
  end
end
