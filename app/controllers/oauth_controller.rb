require "net/http"
require "uri"
require "json"

class OauthController < ApplicationController
  # 定数
  # OAuth認証で使用するクライアントIDとシークレット
  CLIENT_ID = "QIxpef6SBoaxCNOxbpcDvFz0NRuVE05CX63Y0PhRmCs".freeze
  CLIENT_SECRET = "tn0nkTC434IBQXh2bvsFxm9_Kofy3VqwaKgBt28VsKo".freeze

  # 認証後のリダイレクト URL
  REDIRECT_URI = "http://localhost:3000/oauth/callback".freeze

  # OAuth認証用エンドポイント
  AUTH_URL = "http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/authorize".freeze
  TOKEN_URL = "http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/token".freeze

  # OAuth認証リクエストパラメータ
  RESPONSE_TYPE = "code".freeze
  SCOPE = "write_tweet".freeze

  # アクセストークン関連の定数
  ACCESS_TOKEN_KEY = "access_token".freeze
  GRANT_TYPE_AUTHORIZATION_CODE = "authorization_code".freeze

  # エラーメッセージ
  ERROR_CODE_NOT_FOUND = "認可コードが見つかりません".freeze
  ERROR_ACCESS_TOKEN_FAILURE = "アクセストークンの取得に失敗しました".freeze

  def redirect
    # OAuth認証URLを生成し、リダイレクト
    redirect_to build_auth_url, allow_other_host: true
  end

  def callback
    code = params[:code]

    # 認可コードが存在しない場合はエラー
    if code.blank?
      render plain: ERROR_CODE_NOT_FOUND, status: :bad_request
      return
    end

    # 認可コードを使用してアクセストークン取得
    token_response = fetch_access_token(code)

    # アクセストークンを取得出来た場合、セッションに保存して写真一覧画面へ
    if token_response[ACCESS_TOKEN_KEY].present?
      session[:access_token] = token_response[ACCESS_TOKEN_KEY]
      redirect_to photos_path
    else
      render plain: ERROR_ACCESS_TOKEN_FAILURE, status: :unprocessable_entity
    end
  end

  private

  def build_auth_url
    query_params = {
      client_id: CLIENT_ID,
      response_type: RESPONSE_TYPE,
      redirect_uri: REDIRECT_URI,
      scope: SCOPE
    }

    URI.join(AUTH_URL, "?#{query_params.to_query}").to_s
  end

  def fetch_access_token(code)
    uri = URI(TOKEN_URL)

    # 認可コードを使用してアクセストークン取得
    response = Net::HTTP.post_form(uri, {
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      redirect_uri: REDIRECT_URI,
      grant_type: GRANT_TYPE_AUTHORIZATION_CODE,
      code: code
    })

    begin
      # レスポンスのJSONを解析して、結果を返す
      JSON.parse(response.body)
    rescue JSON::ParserError
      # 解析に失敗した場合のエラーハンドリング
      { "error" => "無効なレスポンスを受け取りました" }
    end
  end
end
