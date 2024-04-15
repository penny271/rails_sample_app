require "test_helper"

class UsersLogin < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end
end

# UsersLoginクラスを継承しているため、setupメソッドが呼び出される
class InvalidPasswordTest < UsersLogin

  test "login path" do
    get login_path
    assert_template 'sessions/new'
  end

  test "login with valid email/invalid password" do
    post login_path, params: { session: { email:    @user.email,
                                          password: "invalid" } }
    assert_not is_logged_in?
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end

# UsersLoginクラスを継承しているため、setupメソッドが呼び出される
class ValidLogin < UsersLogin

  def setup
    super
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
  end
end

# ValidLoginクラスを継承しているため、setupメソッドが呼び出される
class ValidLoginTest < ValidLogin

  test "valid login" do
    assert is_logged_in?
    assert_redirected_to @user
  end

  test "redirect after login" do
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end

class Logout < ValidLogin

  def setup
    super
    delete logout_path
  end
end

# Logoutクラスを継承しているため、setupメソッドが呼び出される
class LogoutTest < Logout

  test "successful logout" do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "redirect after logout" do
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "should still work after logout in second window" do
    delete logout_path   # ログアウト sessions#destroy発動
    assert_redirected_to root_url
  end
end

class RememberingTest < UsersLogin

  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    # * リスト 9.26の統合テストでは、仮想のremember_token属性にアクセスできないと説明しましたが、実は、assignsという特殊なテストメソッドを使うとアクセスできるようになります。コントローラで定義したインスタンス変数にテストの内部からアクセスするには、テスト内部でassignsメソッドを使います。
    assert_equal cookies['remember_token'], assigns(:user).remember_token
    # assert_not cookies[:remember_token].blank?
  end

  test "login without remembering" do
    # Cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    # Cookieが削除されていることを検証してからログイン
    log_in_as(@user, remember_me: '0')
    assert cookies[:remember_token].blank?
  end
end