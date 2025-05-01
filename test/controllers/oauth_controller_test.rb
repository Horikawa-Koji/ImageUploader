require "test_helper"

class OauthControllerTest < ActionDispatch::IntegrationTest
  test "should get redirect" do
    get oauth_redirect_url
    assert_response :success
  end

  test "should get callback" do
    get oauth_callback_url
    assert_response :success
  end
end
