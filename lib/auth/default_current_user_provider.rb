require_dependency "auth/current_user_provider"

class Auth::DefaultCurrentUserProvider

  CURRENT_USER_KEY ||= "_DISCOURSE_CURRENT_USER".freeze
  API_KEY ||= "api_key".freeze
  API_KEY_ENV ||= "_DISCOURSE_API".freeze
  TOKEN_COOKIE ||= "_t".freeze
  PATH_INFO ||= "PATH_INFO".freeze

  # do all current user initialization here
  def initialize(env)
    @env = env
    @request = Rack::Request.new(env)
  end

  # our current user, return nil if none is found
  def current_user
    return @env[CURRENT_USER_KEY] if @env.key?(CURRENT_USER_KEY)

    if fetch_user_from_maishoudang
      return @env[CURRENT_USER_KEY] = current_user = fetch_user_from_maishoudang
    end

    request = @request

    auth_token = request.cookies[TOKEN_COOKIE]

    current_user = nil

    if auth_token && auth_token.length == 32
      current_user = User.find_by(auth_token: auth_token)
    end

    if current_user && (current_user.suspended? || !current_user.active)
      current_user = nil
    end

    if current_user && should_update_last_seen?
      u = current_user
      Scheduler::Defer.later "Updating Last Seen" do
        u.update_last_seen!
        u.update_ip_address!(request.ip)
      end
    end

    # possible we have an api call, impersonate
    if api_key = request[API_KEY]
      current_user = lookup_api_user(api_key, request)
      raise Discourse::InvalidAccess unless current_user
      @env[API_KEY_ENV] = true
    end

    @env[CURRENT_USER_KEY] = current_user
  end

  def log_on_user(user, session, cookies)
    unless user.auth_token && user.auth_token.length == 32
      user.auth_token = SecureRandom.hex(16)
      user.save!
    end
    cookies.permanent[TOKEN_COOKIE] = { value: user.auth_token, httponly: true }
    make_developer_admin(user)
    @env[CURRENT_USER_KEY] = user
  end

  def make_developer_admin(user)
    if  user.active? &&
        !user.admin &&
        Rails.configuration.respond_to?(:developer_emails) &&
        Rails.configuration.developer_emails.include?(user.email)
      user.admin = true
      user.save
    end
  end

  def log_off_user(session, cookies)
    cookies[TOKEN_COOKIE] = nil
  end


  # api has special rights return true if api was detected
  def is_api?
    current_user
    @env[API_KEY_ENV]
  end

  def has_auth_cookie?
    cookie = @request.cookies[TOKEN_COOKIE]
    !cookie.nil? && cookie.length == 32
  end

  def should_update_last_seen?
    !(@request.path =~ /^\/message-bus\//)
  end

  protected

  def lookup_api_user(api_key_value, request)
    api_key = ApiKey.where(key: api_key_value).includes(:user).first
    if api_key
      api_username = request["api_username"]
      if api_key.user
        api_key.user if !api_username || (api_key.user.username_lower == api_username.downcase)
      elsif api_username
        User.find_by(username_lower: api_username.downcase)
      else
        nil
      end
    end
  end

  def fetch_user_from_maishoudang
    @request.session[:init] = true unless @request.session[:init].eql?(true)

    user_info = @request.session['devise.maishoudang.user_info'] || return

    user = User.find_by(email: user_info[:email])
    unless user
      user = User.create!(email: user_info[:email], username: user_info[:username], password: SecureRandom.hex(8))
    end

    user
  end

end
