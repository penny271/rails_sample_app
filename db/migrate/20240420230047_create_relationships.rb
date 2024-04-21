# db/migrate/20240420230047_create_relationships.rb

class CreateRelationships < ActiveRecord::Migration[7.0]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    # relationshipsテーブルにインデックスを追加する
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # follower_idとfollowed_idの組み合わせが重複しないよう保証する仕組みです。
    # これにより、あるユーザーが同じユーザーを2回以上フォローできないようにします4 。
    add_index :relationships, [:follower_id, :followed_id], unique: true # 複合インデックス
  end
end
