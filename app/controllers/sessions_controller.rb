class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  # 定数
  # エラーメッセージ（フォームの入力チェック時に使用）
  EMAIL_ERROR_MESSAGE = "・ユーザーIDを入力してください。".freeze
  PASSWORD_ERROR_MESSAGE = "・パスワードを入力してください。".freeze
  LOGIN_ERROR_MESSAGE = "・ユーザーIDとパスワードが⼀致しません。".freeze

  # エラーメッセージの区切り（HTML側で改行として利用）
  MESSAGE_SEPARATOR = "\n".freeze

  def new
  end

  def create
    # ユーザーIDとパスワードの入力チェック
    err_message = check_input
    unless err_message.empty?
      redirect_to new_session_path, alert: make_display_message(err_message)
      return
    end

    # ユーザーチェック
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: LOGIN_ERROR_MESSAGE
    end
  end

  def destroy
    session.delete(:access_token)  # アクセストークンを削除（ログアウト時の処理）
    terminate_session
    redirect_to new_session_path
  end

  private
    # フォーム入力のバリデーション
    # ユーザーIDとパスワードの入力チェックを行い、不足があればエラーメッセージを返す
    def check_input
      errors = []
      errors << EMAIL_ERROR_MESSAGE if params[:email_address].blank?
      errors << PASSWORD_ERROR_MESSAGE if params[:password].blank?
      errors
    end

    # 複数のエラーメッセージを連結し、表示用の形式に変換
    def make_display_message(message_list)
      message_list.join(MESSAGE_SEPARATOR)
    end
end
