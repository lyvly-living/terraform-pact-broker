
class BasicAuth
  PATH_INFO = 'PATH_INFO'.freeze
  REQUEST_METHOD = 'REQUEST_METHOD'.freeze
  GET = 'GET'.freeze
  OPTIONS = 'OPTIONS'.freeze
  HEAD = 'HEAD'.freeze
  READ_METHODS = [GET, OPTIONS, HEAD].freeze

  def initialize(app, write_user_username, write_user_password, read_user_username, read_user_password)
    @app = app
    @write_credentials = [write_user_username, write_user_password]
    @read_credentials = [read_user_username, read_user_password]
    @app_with_write_auth = build_app_with_write_auth
    @app_with_read_auth = build_app_with_read_auth
  end

  def call(env)
    if read_request?(env)
      app_with_read_auth.call(env)
    else
      app_with_write_auth.call(env)
    end
  end

  protected

  def write_credentials_match(*credentials)
    credentials == write_credentials
  end

  def read_credentials_match(*credentials)
    credentials == read_credentials
  end

  private

  attr_reader :app, :app_with_read_auth, :app_with_write_auth, :write_credentials, :read_credentials

  def build_app_with_write_auth
    this = self
    Rack::Auth::Basic.new(app, "Write access required") do |username, password|
      this.write_credentials_match(username, password)
    end
  end

  def build_app_with_read_auth
    this = self
    Rack::Auth::Basic.new(app, "Read access required") do |username, password|
      this.write_credentials_match(username, password) || this.read_credentials_match(username, password)
    end
  end

  def read_request?(env)
    READ_METHODS.include?(env[REQUEST_METHOD])
  end
end