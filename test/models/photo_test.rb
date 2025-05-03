require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  def setup
    @valid_image = Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/sample.jpg"), "image/jpeg")
  end

  test "タイトルがない場合、エラーが発生する" do
    photo = Photo.new(title: nil, featured_image: @valid_image)
    assert_not photo.valid?
    assert_includes photo.errors[:base], Photo::TITLE_REQUIRED_MESSAGE
  end

  test "タイトルが30文字を超える場合、エラーが発生する" do
    long_title = "a" * 31
    photo = Photo.new(title: long_title, featured_image: @valid_image)
    assert_not photo.valid?
    assert_includes photo.errors[:base], Photo::TITLE_TOO_LONG_MESSAGE
  end

  test "画像がない場合、エラーが発生する" do
    photo = Photo.new(title: "Valid Title", featured_image: nil)
    assert_not photo.valid?
    assert_includes photo.errors[:base], Photo::IMAGE_REQUIRED_MESSAGE
  end

  test "タイトルと画像が適切な場合、正常に保存できる" do
    photo = Photo.new(title: "Valid Title", featured_image: @valid_image)
    assert photo.valid?
  end
end
