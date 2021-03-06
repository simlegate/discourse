class Auth::MaishoudangAuthenticator < Auth::Authenticator

  def name
    "maishoudang"
  end

  def after_authenticate(auth_token)
    
    result = Auth::Result.new

    data = auth_token[:info]

    result.username = username = data["username"]
    result.email = email = data["email"]

    maishoudang_user_id = auth_token["uid"]

    result.extra_data = {
      maishoudang_user_id: maishoudang_user_id,
      maishoudang_user_name: username,
    }

    user_info = MaishoudangUserInfo.find_by(maishoudang_user_id: maishoudang_user_id)

    if user_info
      user = user_info.user
    elsif user = User.find_by_email(email)
      user_info = MaishoudangUserInfo.create(
        user_id: user.id,
        username: username,
        maishoudang_user_id: maishoudang_user_id 
      )
    end

    result.user = user
    result.email_valid = false

    result
  end


  def after_create_account(user, auth)
    data = auth[:extra_data]
    MaishoudangUserInfo.create(
      user_id: user.id,
      username: data[:username],
      maishoudang_user_id: data[:maishoudang_user_id]
    )
  end


  def register_middleware(omniauth)
    omniauth.provider :maishoudang,
           :setup => lambda { |env|
              strategy = env["omniauth.strategy"]
              strategy.options[:client_id] = SiteSetting.maishoudang_app_id
              strategy.options[:client_secret] = SiteSetting.maishoudang_app_secret
           },
           # :scope => "user",
           :provider_ignores_state => true
  end
end
