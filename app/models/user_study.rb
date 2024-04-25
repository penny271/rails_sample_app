# app/models/user.rb
class User < ApplicationRecord
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy

  has_many :following, through: "active_relationships", source: "followed"

  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy

  has_many :followers, through: "passive_relationships", source: "follower"
end


# ! 下記のようにシンボルを使ったほうが rails的には好ましい 2024/04/24
# has_many :active_relationships, class_name: :Relationship, foreign_key: :follower_id, dependent: :destroy


# Userモデル:
# has_many :active_relationships: これはUserが多くのアクティブなリレーションシップを持っており、これらはRelationshipモデルのインスタンスであることを指定します。ここでのforeign_keyはfollower_idで、このユーザーがフォロワーとしての関係を指します。dependent: :destroyは、ユーザーが削除された場合、そのユーザーの全てのアクティブなリレーションシップも削除されることを意味します。

# has_many :following, through: "active_relationships", source: "followed": このアソシエーションを通じて、ユーザーがフォローしている他のユーザーを参照します。ここではactive_relationshipsを経由し、そのリレーションシップのfollowed属性（つまりフォローされているユーザー）からデータを取得します。

# has_many :passive_relationships: これはUserが多くのパッシブなリレーションシップを持っており、これらもRelationshipモデルのインスタンスですが、foreign_keyはfollowed_idです。これはこのユーザーがフォローされる側の関係を指します。同じくdependent: :destroyオプションが設定されています。

# has_many :followers, through: "passive_relationships", source: "follower": このアソシエーションを通じて、ユーザーをフォローしている他のユーザーを参照します。ここではpassive_relationshipsを経由し、そのリレーションシップのfollower属性（つまりフォロワー）からデータを取得します。

# Relationshipモデル:
# belongs_to :follower: このRelationshipはUserモデルに属しており、follower_idを外部キーとして使用します。ここでfollowerはフォローするユーザーを指します。
# belongs_to :followed: 同様に、このRelationshipは別のUserモデルに属しており、followed_idを外部キーとして使用します。followedはフォローされるユーザーを指します。