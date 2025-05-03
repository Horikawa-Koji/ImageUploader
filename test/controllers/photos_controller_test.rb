require "test_helper"
require "ostruct"

class PhotosControllerTest < ActionDispatch::IntegrationTest
  setup do
    # ダミーユーザーを作成し、ログイン状態にする
    @user = User.create!(email_address: "test@example.com", password: "password")
    post session_path, params: { email_address: @user.email_address, password: "password" }

    # 画像をセットしたテスト用の写真データを作成
    @photo = Photo.create!(
      title: "Test Photo",
      featured_image: fixture_file_upload("test/fixtures/sample.jpg", "image/jpeg")
    )
  end

  def mock_post_tweet(response)
    PhotosController.class_eval do
      define_method(:post_tweet) do |_photo|
        response
      end
    end
  end

  test "写真一覧ページが表示できる" do
    get photos_url
    assert_response :success
  end

  test "写真を新規作成できる" do
    assert_difference "Photo.count", 1 do
      post photos_url, params: { photo: { title: "New Photo", featured_image: fixture_file_upload("test/fixtures/sample.jpg", "image/jpeg") } }
    end
    assert_redirected_to photos_url
  end

  test "認証済みユーザーがツイートに成功すると、成功メッセージが表示される" do
    mock_post_tweet(OpenStruct.new(code: "201"))

    post tweet_photo_url(@photo)
    assert_redirected_to photos_url
    assert_equal PhotosController::TWEET_SUCCESS_MESSAGE, flash[:notice]
  end

  test "ツイートに失敗すると、エラーメッセージが表示される" do
    mock_post_tweet(OpenStruct.new(code: "400", body: { "error" => "APIエラー" }.to_json))

    post tweet_photo_url(@photo)
    assert_redirected_to photos_url
    assert_match /ツイートに失敗しました: APIエラー/, flash[:alert]
  end

  test "ツイート時に予期しないエラーが発生すると、デフォルトのエラーメッセージが表示される" do
    mock_post_tweet(OpenStruct.new(code: "500", body: nil))

    post tweet_photo_url(@photo)
    assert_redirected_to photos_url
    assert_match /ツイートに失敗しました: 不明なエラーが発生しました/, flash[:alert]
  end

  test "写真を削除できる" do
    assert_difference "Photo.count", -1 do
      delete photo_url(@photo)
    end
    assert_redirected_to photos_url
  end
end
