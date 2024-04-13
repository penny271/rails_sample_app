# app/models/user.rb
class User < ApplicationRecord
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
  validates :password, presence: true, length: { minimum: 6 }
end
