require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }

    # この例では、CSSセレクタ'div.alert'が、クラス "alert "を持つすべての<div>要素を選択するために使われています。2番目の引数 'The form contains 4 errors.' は、選択された要素の期待されるテキスト内容です。
    assert_select 'div.alert', 'The form contains 4 errors.'
    assert_template 'users/edit'
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload # * ユーザーの情報をデータベースから再読み込み
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end
