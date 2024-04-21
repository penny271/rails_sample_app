# app/models/relationship.rb
class Relationship < ApplicationRecord
  # * Relationshipはfollowerとfollowedの2つの属性を持つ
  # * followerとfollowedはUserモデルと関連付けられている
  # - follower(※User) (1)-> relationships <-(1) followedr(※User) の関係
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
