require 'net/http'
require 'uri'
require 'json'

class OauthController < ApplicationController
  # 定数
  CLIENT_ID = "QIxpef6SBoaxCNOxbpcDvFz0NRuVE05CX63Y0PhRmCs".freeze
  CLIENT_SECRET = "tn0nkTC434IBQXh2bvsFxm9_Kofy3VqwaKgBt28VsKo".freeze
  REDIRECT_URI = "http://localhost:3000/oauth/callback".freeze
  AUTH_URL = "http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/authorize".freeze
  TOKEN_URL = "http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/token".freeze
  RESPONSE_TYPE = "code".freeze
  SCOPE = "write_tweet".freeze
  ACCESS_TOKEN_KEY = "access_token".freeze
  GRANT_TYPE_AUTHORIZATION_CODE = "authorization_code".freeze

  # エラーメッセージ
  ERROR_CODE_NOT_FOUND = "認可コードが見つかりません".freeze
  ERROR_ACCESS_TOKEN_FAILURE = "アクセストークンの取得に失敗しました".freeze

  def redirect
    query_params = {
      client_id: CLIENT_ID,
      response_type: RESPONSE_TYPE,
      redirect_uri: REDIRECT_URI,
      scope: SCOPE
    }

    redirect_to "#{AUTH_URL}?#{query_params.to_query}", allow_other_host: true
  end

  def callback
    code = params[:code]

    if code.blank?
      render plain: ERROR_CODE_NOT_FOUND, status: :bad_request
      return
    end

    # アクセストークン取得のリクエスト
    token_response = fetch_access_token(code)

    # アクセストークンを取得出来たらセッションに保存して、写真一覧画面へ
    if token_response[ACCESS_TOKEN_KEY].present?
      session[:access_token] = token_response[ACCESS_TOKEN_KEY]
      redirect_to photos_path
    else
      render plain: ERROR_ACCESS_TOKEN_FAILURE, status: :unprocessable_entity
    end
  end

  private

  def fetch_access_token(code)
    uri = URI(TOKEN_URL)

    response = Net::HTTP.post_form(uri, {
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      redirect_uri: REDIRECT_URI,
      grant_type: GRANT_TYPE_AUTHORIZATION_CODE,
      code: code
    })

    JSON.parse(response.body)
  end
end
