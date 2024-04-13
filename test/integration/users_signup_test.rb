require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
    # エラーメッセージをテストするためのテンプレート
    assert_select 'div#error_explanation'
    assert_select 'div.alert.alert-danger'
  end

  # 有効なユーザー登録に対するテスト
  test "valid signup information" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    # * ユーザープロフィールに関するほぼ全て（例: ページにアクセスしたらなんらかの理由でエラーが発生しないかどうか）をテストできていることになります。この類のエンドツーエンドテストは、アプリケーションの重要な機能をカバーしてくれています。こういった理由が統合テストが便利だと呼ばれる所以です。
    assert_template 'users/show'
  end
end
