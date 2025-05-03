require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(email_address: "  Example@Email.com  ", password: "secure123", password_confirmation: "secure123")
  end

  test "パスワードがハッシュ化され、認証できる" do
    assert @user.save
    assert_not_nil @user.password_digest
    assert @user.authenticate("secure123")
    assert_not @user.authenticate("wrongpassword")
  end

  test "セッションを持つことができる" do
    @user.save
    session = @user.sessions.create
    assert session.persisted?
    assert_equal @user.id, session.user_id
  end

  test "メールアドレスが正規化される" do
    @user.save
    assert_equal "example@email.com", @user.reload.email_address
  end
end
