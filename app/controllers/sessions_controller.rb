class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
#  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  # 定数
  EMAIL_ERROR_MESSAGE = "・ユーザーIDを入力してください。".freeze
  PASSWORD_ERROR_MESSAGE = "・パスワードを入力してください。".freeze
  LOGIN_ERROR_MESSAGE = "・ユーザーIDとパスワードが⼀致しません。".freeze
  MESSAGE_SEPARATOR = "<br>".freeze

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
    session.delete(:access_token)  # セッションからアクセストークンを削除
    terminate_session
    redirect_to new_session_path
  end

  private
    # 入力チェック
    def check_input
      [].tap do |err_message|
        err_message << EMAIL_ERROR_MESSAGE if params[:email_address].blank?
        err_message << PASSWORD_ERROR_MESSAGE if params[:password].blank?
      end
    end

    # 表示用メッセージの作成
    def make_display_message(message_list)
      message_list.join(MESSAGE_SEPARATOR)
    end
end
