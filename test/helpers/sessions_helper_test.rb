require "test_helper"

# テスト手順はシンプルです。

# fixtureでuser変数を定義する
# 渡されたユーザーをrememberメソッドで記憶する
# current_userが、渡されたユーザーと同じであることを確認する
# 上の手順ならrememberメソッドによってsession[:user_id]が設定されないので、これで問題となっている複雑な分岐処理もテストできるようになります。

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
