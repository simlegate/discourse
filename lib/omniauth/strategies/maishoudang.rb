require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Maishoudang < OmniAuth::Strategies::OAuth2
      option :name, "maishoudang" 
      option :client_options, { site: 'http://lvh.me:3000' }

      uid { raw_info['id'] }

      info do
        {
          :username => raw_info['username'],
          :username_pinyin => raw_info['username_pinyin'],
          :email => raw_info['email']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/oauth/me.json').parsed
      end
    end
  end
end

