require 'omniauth-oauth2'
 
class OmniAuth::Strategies::Maishoudang < OmniAuth::Strategies::OAuth2
  option :name, "maishoudang" 
  option :client_options, site: 'http://maishoudang.com'

  uid { raw_info['id'] }

  info do
    {
      :username => raw_info['username'],
      :name => raw_info['name'],
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
