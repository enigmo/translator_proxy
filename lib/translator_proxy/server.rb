require 'sinatra/base'
require 'sinatra/json'
require 'json'

module TranslatorProxy
  class Server < ::Sinatra::Base
    get '/' do
      #invalid_access unless check_access
      translated = translator.translate(translate_params[:text], translate_params)
      json :result => translated
    end

    def check_access
      if settings.require_referrer? && !(request.referrer && request.referrer.match(settings.require_referrer))
        return false
      end
      if settings.require_param? && !settings.require_param.call(params)
        return false
      end
      true
    end

    def invalid_access
      halt 403
    end

    def translate_params
      {
        :text => params[:text],
        :from => params[:from],
        :to   => params[:to]
      }
    end

    def translator
      ::TranslatorProxy
    end
  end
end
