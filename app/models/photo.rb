class Photo < ApplicationRecord
  has_one_attached :featured_image
  validate :title_and_image_checks

  # 定数
  TITLE_REQUIRED_MESSAGE = "タイトルを入力してください。".freeze
  TITLE_TOO_LONG_MESSAGE = "タイトルは30文字以下で入力してください。".freeze
  IMAGE_REQUIRED_MESSAGE = "画像をアップロードしてください。".freeze
  TITLE_MAX_LENGTH = 30

  private
  def title_and_image_checks
    errors.add(:base, TITLE_REQUIRED_MESSAGE) if title.blank?
    errors.add(:base, TITLE_TOO_LONG_MESSAGE) if title.present? && title.length > TITLE_MAX_LENGTH
    errors.add(:base, IMAGE_REQUIRED_MESSAGE) if featured_image.blank?
  end

end
