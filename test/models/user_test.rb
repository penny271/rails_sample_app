require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup
    # * has_secure_passwordを使って新しいカラムに値が必要なため、passwordとpassword_confirmationを追加
    @user = User.new(name: "Example User", email: "user@example.com",
      password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    # assert_notメソッドを使って Userオブジェクトが有効でなくなったことを確認します
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    # assert_notメソッドを使って Userオブジェクトが有効でなくなったことを確認します
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    # * 通常、メールアドレスでは大文字小文字が区別されません。
    # * すなわち、foo@bar.comはFOO@BAR.COMやFoO@BAr.coMと書いても扱いは同じです。
    # duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  # * 記憶ダイジェストを持たないユーザーを用意し（setupメソッドで定義した@userインスタンス変数ではtrueになります）、続いてauthenticated?を呼び出します（リスト 9.18）。この中で、記憶トークンを空欄のままにしていることにご注目ください。記憶トークンが使われる前にエラーが発生するので、記憶トークンはどんな値でも構わないのです。
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  # dependent: :destroyのテスト
  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
end

# このコードは、Ruby on Railsのモデルテストを定義しています。具体的には、Userモデルのテストを行っています。

# まず、test_helperをrequireしています。test_helperは、テストを行うための各種設定やヘルパーメソッドを提供します。これにより、テストコードの中でRailsの各種機能を利用することができます。

# 次に、UserTestクラスを定義しています。このクラスはActiveSupport::TestCaseを継承しており、これによりRailsのテストフレームワークの機能を利用することができます。

# setupメソッドでは、テストを行う前の準備を行っています。ここでは新しいUserインスタンスを作成し、それを@userインスタンス変数に格納しています。この@userインスタンス変数は、後続のテストメソッドで使用されます。

# 最後に、"should be valid"というテストを定義しています。このテストでは、@userが有効（valid）であることを確認しています。assertメソッドは、引数が真であることを確認します。つまり、@user.valid?がtrueを返すことを期待しています。もし@user.valid?がfalseを返すと、このテストは失敗します。

# このように、このコードはUserモデルが正しく動作することを確認するためのテストを提供しています。