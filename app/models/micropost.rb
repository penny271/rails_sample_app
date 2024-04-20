class Micropost < ApplicationRecord
  belongs_to :user
  #  * Micropostモデルに画像を追加するために、Active Storageを使っている
  # * 1つの画像を添付する
  has_one_attached :image do |attachable|
    # * Active Storageが提供するvariantメソッドで変換済み画像を作成できます。次のように、resize_to_limitオプションを指定して、画像の幅と高さが500ピクセルを超えないように制約をかけることにします。
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  # default_scopeは、データベースから要素を取得するときに、デフォルトの順序を指定するメソッド
  # 全てのMicropostを作成日時の降順で取得するようにしている
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  # * 画像のバリデーションを追加 gem active_storage_validations を使っている
  validates :image,   content_type: { in: %w[image/jpeg image/gif image/png],
                                      message: "must be a valid image format" },
                                      size:         { less_than: 5.megabytes,
                                      message:   "should be less than 5MB" }
end
