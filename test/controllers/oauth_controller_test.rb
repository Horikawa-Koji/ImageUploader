require "test_helper"

class OauthControllerTest < ActionDispatch::IntegrationTest
  setup do
    # ダミーユーザーを作成し、ログイン状態にする
    @user = User.create!(email_address: "test@example.com", password: "password")
    post session_path, params: { email_address: @user.email_address, password: "password" }
  end

  def mock_fetch_access_token(response)
    OauthController.class_eval do
      define_method(:fetch_access_token) do |_code|
        response
      end
    end
  end

  test "OAuth認証URLにリダイレクトする" do
    get oauth_redirect_url
    assert_redirected_to /#{OauthController::AUTH_URL}/
  end

  test "認可コードなしの場合、エラーを返す" do
    get oauth_callback_url
    assert_response :bad_request
    assert_equal OauthController::ERROR_CODE_NOT_FOUND, response.body
  end

  test "認可コードありの場合、アクセストークンを取得しリダイレクト" do
    mock_fetch_access_token({ "access_token" => "fake_token" })

    get oauth_callback_url, params: { code: "valid_code" }
    assert_redirected_to photos_url
    assert_equal "fake_token", session[:access_token]
  end

  test "アクセストークン取得失敗時、エラーを返す" do
    mock_fetch_access_token({ "error" => "invalid_request" })

    get oauth_callback_url, params: { code: "invalid_code" }
    assert_response :unprocessable_entity
    assert_equal OauthController::ERROR_ACCESS_TOKEN_FAILURE, response.body
  end
end
