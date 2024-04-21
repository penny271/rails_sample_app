# app/models/user.rb
class User < ApplicationRecord
  # * 1つのユーザーが複数のマイクロポストを持つ
  has_many :microposts, dependent: :destroy
  # * 1つのユーザーが複数のアクティビティを持つ フォロー機能のため
  # * has_many側にforeign_keyを指定することで、Userモデルのidカラムとfollower_idカラムを関連付ける
  has_many :active_relationships, class_name:  "Relationship",
  # sqlで複数の同じ外部キーからそれに対応するレコードを取得することで一括で自分がフォローしている人のレコードを取得できる
                                  foreign_key: "follower_id",
                                  dependent:   :destroy

  has_many :passive_relationships, class_name:  "Relationship",
  # sqlで複数の同じ外部キーからそれに対応するレコードを取得することで一括で自分をフォローしている人のレコードを取得できる
                                  foreign_key: "followed_id",
                                  dependent:   :destroy

  # * 1つのユーザーが複数のアクティビティを持つ フォロー機能のため
  # * :sourceパラメーターを使って、「following配列の出どころ（source）はfollowed idのコレクションである」ことを明示的にRailsに伝える
  # - この行は、「ユーザーがフォローしている人々（following）」を取得するためのアソシエーションです。ここでは、active_relationshipsを介して、具体的にはRelationshipテーブルのfollowed_idを通じて、フォローしているユーザーを参照します。

  # - source: :followedは、active_relationshipsアソシエーションを通じて参照される先（つまり「フォローされているユーザー」を指すRelationshipレコードのfollowed_idフィールド）を指定します。この設定により、Userモデルのインスタンス（user）に対してuser.followingを呼び出すと、そのユーザーによってフォローされている全てのユーザーのリストが返されます。
  #  ! source: :followedは、has_many :following, through: :active_relationshipsアソシエーションを定義する際に、最終的に取得したいレコード（つまり、フォローしているユーザー）を指定しています。
  has_many :following, through: :active_relationships, source: :followed # フォローする側(follower_id)から見ている
  # - user.following.include?(other_user) が使えるようになる
  # - user.following.find(other_user) が使えるようになる
  # * 誰にフォローされているかを知りたい　
  # 規約に則っているので、下記のsourceは省略可能
  has_many :followers, through: :passive_relationships, source: :follower # フォローされる側(followed_id)から見ている

  # * どう考えればいいか
  # フォローする側（active_relationships）：自分が他の人をフォローする場合、自分はその関係のfollowerです。そのため、foreign_keyは自分のIDを示すfollower_idです。
  # フォローされる側（passive_relationships）：自分が他の人からフォローされる場合、自分はその関係のfollowedです。そのため、foreign_keyは自分のIDを示すfollowed_idです。

  attr_accessor :remember_token, :activation_token, :reset_token # * 仮想の属性を作成する

  # * ユーザーをデータベースに保存する前にemail属性を強制的に小文字に変換する
  # * これにより、大文字と小文字を区別しない一意性が保証される
  # before_save { self.email = email.downcase }
  # before_save { email.downcase! } # * この行は上の行と同じ意味 直接変更することができる
  # * 上記をメソッド参照に書き換えた
  before_save   :downcase_email # オブジェクトが新規に作成される場合も更新される場合も実行される
  # オブジェクトが新規に作成されてデータベースに初めて保存される直前にのみ実行される
  before_create :create_activation_digest

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
  # def authenticated?(remember_token)
  #   return false if remember_digest.nil? # * remember_digest ダイジェストが存在しない場合に対応 後続でnilによるエラーを回避
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  # 上記の関数をメタプログラミングでリファクタリング
  def authenticated?(attribute, token)
    # digest = self.send("#{attribute}_digest")
    # * このコードはUserモデル内にあるのでselfは省略可能です。
    digest = send("#{attribute}_digest") # * userモデルの属性の値を動的に取得する
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する * インスタンスメソッド
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    # * validationを避けるため2回update_attributeを呼び出している
    # self.update_attribute(:activated,    true)
    # self.update_attribute(:activated_at, Time.zone.now)

    # update_attribute(:activated,    true)
    # update_attribute(:activated_at, Time.zone.now)

    # * 上記を一つにまとめて書くことのできるメソッド
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    # app/mailers/user_mailer.rb (生成されたファイル)
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    # update_attribute(:reset_digest,  User.digest(reset_token))
    # update_attribute(:reset_sent_at, Time.zone.now)

    # * 上記を一つにまとめて書くことのできるメソッド
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    # app/mailers/user_mailer.rb (生成されたファイル)
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  # * 「〜より少ない」よりも「〜より早い」と捉える方が理解しやすくなります。つまり、この< 記号は「〜より早い時刻」と読んでください。
  # * これなら「パスワード再設定メールの送信時刻が、現在時刻より2時間以上前（早い）の場合」となり、 期待どおりの条件となります。
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # 試作feedの定義 = feedとは自分の投稿のことですでに存在する投稿
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  def feed
    # self.microposts  # テーブルのuser_idカラムにidが一致するものを取得
    # microposts  # テーブルのuser_idカラムにidが一致するものを取得 selfは省略可能
    # Micropost.where("user_id = ?", id) # 上記と同じ意味
    # - 自分のフィードしか表示できてなかったのを、自分の投稿とフォローしているユーザーの投稿も表示できるようにする
    # * following_idsは、has_many :following関連付けを行うとActive Recordによって自動生成されるメソッドです（リスト 14.8）。これにより、関連付けの名前の末尾に_idsを足すだけで、user.followingコレクションに対応するidの配列を取得できます。
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    #  * 上記をSQLのサブセレクトで効率化したもの
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
                     .includes(:user, image_attachment: :blob) # * 画像をプリロードする
  end

  # ユーザーをフォローする
  def follow(other_user)
    # user自身を表すオブジェクトのselfは可能な限り省略している
    following << other_user unless self == other_user
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    # user自身を表すオブジェクトのselfは可能な限り省略している
    following.delete(other_user)
  end

  # 現在のユーザーが他のユーザーをフォローしていればtrueを返す
  def following?(other_user)
    # user自身を表すオブジェクトのselfは可能な限り省略している
    following.include?(other_user)
  end

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      # self.email = email.downcase
      email.downcase! # * この行は上の行と同じ意味 直接変更することができる
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
