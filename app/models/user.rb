# app/models/user.rb
class User < ApplicationRecord
  attr_accessor :remember_token # * 仮想の属性を作成する

  # * ユーザーをデータベースに保存する前にemail属性を強制的に小文字に変換する
  # * これにより、大文字と小文字を区別しない一意性が保証される
  # before_save { self.email = email.downcase }
  before_save { email.downcase! } # * この行は上の行と同じ意味 直接変更することができる
  # validates ${:attribute}, presence: true
  # validates(:name, presence: true)
  # validates('name', 'email', {presence: true}) # * 文字列でもシンボルでもOK
  validates(:name, {presence: true})
  validates :name, length: { maximum: 50 }  # * 文字列でもシンボルでもOK
  # validates :email, length: { maximum: 255 }  # * 文字列でもシンボルでもOK
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: true
                    # uniqueness: { case_sensitive: false }

  # * 2つの仮想的な属性（passwordとpassword_confirmation）が使えるようになる
  has_secure_password
  # validates :password, presence: true, length: { minimum: 6 }
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す(passwordのハッシュ化のため) * クラスメソッド
  # def self.digest(string) # * クラスメソッド
  def User.digest(string) # * クラスメソッド
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す(Remember me機能のため) * クラスメソッド
  # def self.new_token
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token # ランダムなトークンを生成して仮想属性のremember_tokenに代入
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest # * データベースに保存されたダイジェストの値を返す
  end

  # セッションハイジャック防止のためにセッショントークンを返す
  # * この記憶ダイジェストを再利用しているのは単に利便性のため
  def session_token
    remember_digest || remember
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す(Remember me機能のため) * インスタンスメソッド
  def authenticated?(remember_token)
    return false if remember_digest.nil? # * remember_digest ダイジェストが存在しない場合に対応 後続でnilによるエラーを回避
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する * インスタンスメソッド
  def forget
    update_attribute(:remember_digest, nil)
  end
end
