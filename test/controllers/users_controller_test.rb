require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    # get users_new_url
    get signup_path
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  # あるユーザーが異なるユーザーの情報を編集しようとしたときに、ログイン画面にリダイレクトされるかどうかをテストする
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  # あるユーザーが異なるユーザーの情報を更新しようとしたときに、ログイン画面にリダイレクトされるかどうかをテストする
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  # Web経由でadmin属性を変更できないことを確認してみましょう。
  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
                                    user: { password:              "password",
                                            password_confirmation: "password",
                                            admin: true } }
    assert_not @other_user.reload.admin?
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end

  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end

# beforeフィルターはアクションごとに適用されるので、Usersコントローラのテストもアクションごとに書きます。具体的には、正しい種類のHTTPリクエストを使ってeditアクションとupdateアクションをそれぞれ実行し、flashにメッセージが代入されたかどうか、ログイン画面にリダイレクトされたかどうかを確認してみましょう。

# 適切なリクエストはそれぞれGETとPATCHであることがわかるので、テスト内では getメソッドと patchメソッドを使うことにします。setupメソッドを追加することで@user変数を定義しています。