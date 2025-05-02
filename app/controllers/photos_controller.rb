require "net/http"
require "uri"
require "json"

class PhotosController < ApplicationController
  # 定義
  API_ENDPOINT = "http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/api/tweets".freeze
  CONTENT_TYPE = "application/json".freeze
  SUCCESS_STATUS_CODE = 201
  TWEET_SUCCESS_MESSAGE = "ツイートしました".freeze
  TWEET_FAILURE_MESSAGE = "ツイートに失敗しました".freeze
  TWEET_UNKNOWN_ERROR_MESSAGE = "不明なエラーが発生しました".freeze

  def index
    @photos = Photo.order(updated_at: :desc)
    @access_token = session[:access_token]
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = Photo.new(photo_params)
    if @photo.save
      redirect_to photos_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def tweet
    photo = Photo.find(params[:id])

    # Twitter APIへのリクエスト
    response = post_tweet(photo)

    if response.code.to_i == SUCCESS_STATUS_CODE
      redirect_to photos_path, notice: TWEET_SUCCESS_MESSAGE
    else
      error_message = JSON.parse(response.body)["error"] rescue TWEET_UNKNOWN_ERROR_MESSAGE
      redirect_to photos_path, alert: "#{TWEET_FAILURE_MESSAGE}: #{error_message}"
    end
  end

  def show
    @photo = Photo.find(params[:id])
  end

  def destroy
    @photo = Photo.find(params[:id])
    @photo.destroy
    redirect_to photos_path
  end

  private

    def photo_params
      params.require(:photo).permit(:title, :featured_image)
    end

    def post_tweet(photo)
      uri = URI(API_ENDPOINT)

      headers = {
        "Content-Type" => CONTENT_TYPE,
        "Authorization" => "Bearer #{session[:access_token]}"
      }

      # 画像のURLを取得
      image_url = photo.featured_image.attached? ? url_for(photo.featured_image) : nil
      body = {
        text: photo.title,
        url: image_url
      }

      https = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path, headers)
      request.body = body.to_json

      https.request(request)  # Net::HTTPResponse オブジェクトを返す
    end
end
